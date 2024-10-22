package main

import (
	"galil/dmc4000"

	"go.viam.com/rdk/components/motor"
	"go.viam.com/rdk/module"
	"go.viam.com/rdk/resource"
)

func main() {
	module.ModularMain("galil", resource.APIModel{Model: dmc4000.Model, API: motor.API})
}
