# [`galil` module](https://app.viam.com/module/james/galil)

This module implements the [`rdk:component:motor` API](https://www.galil.com/motion-controllers/) in a `DMC4000` model for the [DMC4000](https://www.galil.com/motion-controllers/multi-axis/dmc-40x0)) motor to be used with `viam-server`.

The `DMC4000` model supports stepper motors controlled by [DMC-40x0 series motion controllers](https://www.galil.com/motion-controllers/multi-axis/dmc-40x0). 

The DMC-40x0 controller can drive a variety of motor types, but this Viam module implementation supports only stepper motors at this time.

## Configure your `DMC4000` motor

> [!NOTE]
> Before configuring your motor, you must add a machine in the [Viam app](https://app.viam.com).

Navigate to the **CONFIGURE** tab of your machine's page in [the Viam app](https://app.viam.com).
Click the **+** icon next to your machine part in the left-hand menu and select **Component**.
Select the `motor` type, then select the `galil:DMC4000` model.
Enter a name or use the suggested name for your motor and click **Create**.

On the new component panel, copy and paste the following attribute template into your motor’s attributes field:
```json
{
  "components": [
    {
      "name": "<your-motor-name>",
      "model": "DMC4000",
      "type": "motor",
      "namespace": "rdk",
      "attributes": {
        "amplifier_gain": <int>,
        "low_current": <int>,
        "ticks_per_rotation": <int>,
        "serial_path": <string>,
        "controller_axis": "<your-motion-controller-axis-label>",
        "home_rpm": <int>,
        "max_rpm": <float>,
        "max_acceleration_rpm_per_sec": <float>
      },
      "depends_on": []
    }
  ]
}
```

### Example configurations:

Example configuration for a stepper motor controlled by a DMC-40x0 motion controller:

```json
{
  "components": [
    {
      "name": "my-dmc-motor",
      "model": "DMC4000",
      "type": "motor",
      "namespace": "rdk",
      "attributes": {
        "amplifier_gain": 3,
        "low_current": 1,
        "ticks_per_rotation": 200,
        "serial_path": "/dev/serial/by-path/usb-0:1.1:1.0",
        "controller_axis": "A",
        "home_rpm": 70,
        "max_rpm": 300
      },
      "depends_on": []
    }
  ]
}
```

> [!NOTE]
> For more information, see [Configure a Machine](https://docs.viam.com/configure/).

### Attributes

The following attributes are available for `james:galil:DMC4000` motors:

| Name | Type | Required? | Description |
| ---- | ---- | --------- | ----------- |
|`amplifier_gain` | int | **Required** | Set the [per phase current](https://www.galil.com/download/comref/com4103/index.html#amplifier_gain.html) (when using stepper amp). |
| `low_current` | int | **Required** | Reduce the [hold current](https://www.galil.com/download/comref/com4103/index.html#low_current_stepper_mode.html). |
| `ticks_per_rotation` | int | **Required** | Number of full steps in a rotation. 200 (equivalent to 1.8 degrees per step) is very common. If your data sheet specifies this in terms of degrees per step, divide 360 by that number to get ticks per rotation. |
| `serial_path` | string | Optional | The full filesystem path to the serial device, starting with <file>/dev/</file>. To find your serial device path, first connect the serial device to your machine, then:<ul><li>On Linux, run <code>ls /dev/serial/by-path/\*</code> to show connected serial devices, or look for your device in the output of <code>sudo dmesg \| grep tty</code>. Example: <code>"/dev/serial/by-path/usb-0:1.1:1.0"</code>.</li><li>On macOS, run <code>ls /dev/tty\* \| grep -i usb</code> to show connected USB serial devices, <code>ls /dev/tty\*</code> to browse all devices, or look for your device in the output of <code>sudo dmesg \| grep tty</code>. Example: <code>"/dev/ttyS0"</code>.</li></ul><br>If you do not provide a `serial_path`, the driver will attempt to auto-detect the path to your serial device. |
| `controller_axis` | string | **Required** | Physical port label (A-H); select which "axis" the motor is wired to on the controller. |
| `home_rpm` | int | **Required** | Set speed in revolutions per minute (RPM) that the motor will turn when executing a Home() command (using  DoCommand()). |
| `dir_flip` | bool | Optional | Flip the direction of the signal sent if there is a DIR pin. |
| `max_rpm` | float | Optional | Set a limit on maximum revolutions per minute that the motor can be run at. |
| `max_acceleration_rpm_per_sec` | float | Optional | Set the maximum revolutions per minute (RPM) per second acceleration limit. |

Refer to your motor and motor driver data sheets for specifics.


## Next steps

- To test your motor, go to the [**CONTROL** tab](https://docs.viam.com/fleet/control/).
- To write code against your motor, use one of the [available SDKs](https://docs.viam.com/sdks/).
- To view examples using a motor component, explore [these tutorials](https://docs.viam.com/tutorials/).

## Local development

This module is written in Go.

To build: `make galil`<br>
To test: `make test`


## Extended API

The `DMC4000` model supports additional methods that are not part of the standard Viam motor API as DoCommands. For more information on `do_command`, see the [Viam Motor API Docs](https://docs.viam.com/appendix/apis/components/motor/#docommand).


### Home
Run the DMC homing routine.

#### python
**Parameters:**
- None
**Raises:**
- [(error)](https://grpclib.readthedocs.io/en/latest/errors.html#grpclib.exceptions.GRPCError): An error, if one occurred.

```python
my_motor = Motor.from_robot(robot=robot, name='my_motor')

# Home the motor
home_dict = {
  "command": "home"
}
await my_motor.do_command(home_dict)
```

#### go
**Parameters:**
- `ctx` [(Context)](https://pkg.go.dev/context): A Context carries a deadline, a cancellation signal, and other values across API boundaries.
**Returns:**
- [(error)](https://pkg.go.dev/builtin#error): An error, if one occurred.

```go
// Home the motor
resp, err := myMotorComponent.DoCommand(ctx, map[string]interface{}{"command": "home"})
```

### Jog
Move the motor indefinitely at the specified RPM.

#### python
**Parameters:**
- `rpm` [(float64)](https://pkg.go.dev/builtin#float64): The revolutions per minute at which the motor will turn indefinitely.
**Raises:**
- [(error)](https://grpclib.readthedocs.io/en/latest/errors.html#grpclib.exceptions.GRPCError): An error, if one occurred.

```python
my_motor = Motor.from_robot(robot=robot, name='my_motor')
# Run the motor indefinitely at 70 rpm
jog_dict = {
  "command": "jog",
  "rpm": 70
}
await my_motor.do_command(jog_dict)
```

#### go
**Parameters:**
- `ctx` [(Context)](https://pkg.go.dev/context): A Context carries a deadline, a cancellation signal, and other values across API boundaries.
- `rpm` [(float64)](https://pkg.go.dev/builtin#float64): The revolutions per minute at which the motor will turn indefinitely.
**Returns:**
- [(error)](https://pkg.go.dev/builtin#error): An error, if one occurred.

```go
// Run the motor indefinitely at 70 rpm
resp, err := myMotorComponent.DoCommand(ctx, map[string]interface{}{"command": "jog", "rpm": 70})
```

### Raw
Send [raw string commands](https://www.galil.com/downloads/manuals-and-data-sheets) to the controller.

#### python
**Parameters:**
- `raw_input` [(String)](https://pkg.go.dev/builtin#string): The raw string to send to the controller.
**Raises:**
- [(error)](https://grpclib.readthedocs.io/en/latest/errors.html#grpclib.exceptions.GRPCError): An error, if one occurred.

```python
my_motor = Motor.from_robot(robot=robot, name='my_motor')

raw_dict = {
  "command": "raw",
  "raw_input": "home"
}
await my_motor.do_command(raw_dict)
```

#### go
**Parameters:**
- `ctx` [(Context)](https://pkg.go.dev/context): A Context carries a deadline, a cancellation signal, and other values across API boundaries.
- `raw_input` [(String)](https://pkg.go.dev/builtin#string): The raw string to send to the controller.
**Returns:**
- [(error)](https://pkg.go.dev/builtin#error): An error, if one occurred.

For more information, see the Go SDK Docs on [`Raw`](https://pkg.go.dev/go.viam.com/rdk/components/motor/dmc4000#Motor.Raw) and on [`DoCommand`](https://pkg.go.dev/go.viam.com/rdk/components/motor/dmc4000#Motor.DoCommand).

```go
resp, err := myMotorComponent.DoCommand(ctx, map[string]interface{}{"command": "jog", "raw_input": "home"})
```
