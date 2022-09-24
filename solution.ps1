# task 1: create class Car with the properties: Brand, Model, AmountOfDoors, FuelConsumption, FuelCurrent
# task 2: create methods: ToString, KmPossible, HoursPossible
class Car {
    [string]$Brand
    [string]$Model
    [int]$AmountOfDoors
    [double]$FuelConsumption
    [double]$FuelCurrent
    [double]$ValueKmPossible
	
	# constructor 1
	Car(){
        $this.Brand = 'Undefined'
    }
	
	# constructor 2
    Car(
        [string]$b,
        [string]$m,
        [int]$aod,
        [double]$fco,
        [double]$fcu
    ){
        $this.Brand = $b
        $this.Model = $m
        $this.AmountOfDoors = $aod
        $this.FuelConsumption = $fco
        $this.FuelCurrent = $fcu
        $this.ValueKmPossible = $this.FuelCurrent / $this.FuelConsumption
    }

    [string]ToString(){
        return ("{0}|{1}|{2}|{3}|{4}" -f $this.Brand, $this.Model, $this.AmountOfDoors, $this.FuelConsumption, $this.FuelCurrent)
    }
    [string]KmPossible(){
        $this.ValueKmPossible = $this.FuelCurrent / $this.FuelConsumption
        return ("Car can move {0} km" -f [math]::Round($this.valueKmPossible,2))
    }
    [string]HoursPossible(){
        $this.ValueKmPossible = $this.FuelCurrent / $this.FuelConsumption
        $valueHoursPossible = $this.ValueKmPossible / 100
        return ("Car can move {0} hours (its velocity = 100 km/h)" -f [math]::Round($valueHoursPossible, 2))
    }
}

# task 3: create class CarHandler
# task 4: create method: KmDifference
class CarHandler {
    [int]$Slots = 10
    [Car[]]$Cars = [Car[]]::new($this.Slots)

    [void] AddCar([Car]$car, [int]$slot){
        $this.Cars[$slot] = $car
    }

    [void]RemoveCar([int]$slot){
        $this.Cars[$slot] = $null
    }

    [int[]] GetAvailableSlots(){
        [int]$i = 0
        return @($this.Cars.foreach{ if($_ -eq $null){$i}; $i++})
    }

    [Hashtable] KmDifference(){
        [Hashtable]$hashPairDifference = @{}
        for ($i = 0; $i -lt $this.Slots - 1; $i++)
        {
            for ($j = $i + 1; $j -lt $this.Slots; $j++) 
            {
                $iPairDifference = [math]::Round($this.Cars[$i].ValueKmPossible - $this.Cars[$j].ValueKmPossible, 2)
                $hashPairDifference[$this.Cars[$i].Model + " - " + $this.Cars[$j].Model] = $iPairDifference
            }
        }
        return $hashPairDifference
    }
}

# testing properties of class Car
$myCar = [Car]::new()
$myCar.Brand = "Wolvo"
$myCar.Model = "xc90"
$myCar.AmountOfDoors = 5
$myCar.FuelConsumption = 0.097
$myCar.FuelCurrent = 110.0
Write-Host "carA properties:"
$myCar.ToString()
$myCar.KmPossible()
$myCar.HoursPossible()

$myCarHandler = [CarHandler]::new()

# extract cars' data from JSON file
$json = Get-Content -Path .\cars.json | ConvertFrom-Json
# work with cars' data
for($i = 0; $i -lt $json.psobject.properties.name.Count; $i++)
{
    $property = $json.psobject.properties.name[$i]
    $carI = ("car" +$i)
    # create object of class Car
    $carI = [Car]::new(
        $json.$property.Brand,
        $property,
        $json.$property.AmountOfDoors,
        $json.$property.FuelConsumption,
        $json.$property.FuelCurrent
    )
    # hand over an object to myCarHandler
    $myCarHandler.AddCar($carI, $i)
}
# run method: KmDifference
$pairDifference = $myCarHandler.KmDifference()

#task 5 serialization data => JSON => https
$JSON = $pairDifference | ConvertTo-Json
$JSON | Out-File ".\pair_km_difference.json"
$responce = Invoke-RestMethod -Uri "https://localhost/somemethod" -Method Post -Body $JSON -ContentType "application/json"