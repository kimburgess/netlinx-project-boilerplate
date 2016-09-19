PROGRAM_NAME='duet-util'


#if_not_defined __DUET_UTIL__
#define __DUET_UTIL__

#include 'log.axi'


DEFINE_CONSTANT

// Note, if this is changed you'll need to also update the stacked event
// handler down below. NetLinx appears to not be able to deal with a device
// array in a data event handler.
integer MAX_DUET_IP_DEVICES = 5;


DEFINE_TYPE

structure DuetCommsProperties
{
    dev device
    char address[64]
    integer port
    long baud_rate
    char user_name[64]
    char password[64]
}


define_variable

volatile DuetCommsProperties duetConfig[MAX_DUET_IP_DEVICES]

/**
 * Sets the a property on a Duet virtual device
 *
 * @param   device      the Duet virtual
 * @param   name        the property name
 * @param   value       the value of the property
 */
define_function setProperty(dev device, char name[], char value[])
{
    if (!name)
    {
        warn('No property name supplied, ignoring')
        return
    }

    if (!value)
    {
        warn("'No property value supplied for ', name, ', ignoring'")
        return
    }

    send_command device, "'PROPERTY-', name, ',', value"
}

/**
 * Trigger a Duet module reinitialization.
 *
 * @param   device      the Duet virtual
 */
define_function reinitialize(dev device)
{
    send_command device, "'REINIT'"
}

/**
 * Checks to see if two device addresses are equivalent.
 *
 * @param   a           the first device
 * @param   b           the second device
 * @return              a boolean, true if a is equivalent to b
 */
define_function char devIsEqual(dev a, dev b)
{
    return (a.number == b.number && a.port == b.port && a.system == b.system)
}

/**
 * Checks to see if a device address is 'null'.
 *
 * @param   a           the device address to check
 * @return              a boolean, true if a == 0:0:0
 */
define_function char devIsNull(dev a)
{
    stack_var dev nullDevice
    return devIsEqual(a, nullDevice)
}

/**
 * Convert a dev structure to a printable form.
 *
 * @param   device      the dev to convert
 * @return              a string containing the device in the form d:p:s
 */
define_function char[13] devToString(dev device)
{
    return "itoa(device.number), ':', itoa(device.port), ':', itoa(device.system)"
}

/**
 * Removes wildcards (system 0) from a device address. This is a destructive
 * function and directly acts on the past paremeter.
 *
 * @param   device      the device to convert
 * @return              a boolean, true if the passed device was modified
 */
define_function char devRuntimeAddress(dev device)
{
    if (device.system == 0) {
        device.system = SYSTEM_NUMBER
        return true
    }
    return false
}


/**
 * Retrieve the index of a config slot for the passed Duet virtual device
 */
define_function integer getDuetConfigSlot(dev device)
{
    stack_var integer idx
    stack_var integer slot
    stack_var dev deviceRuntime

    deviceRuntime = device
    devRuntimeAddress(deviceRuntime)

    for (idx = 1; idx <= max_length_array(duetConfig); idx++)
    {
        if (devIsNull(duetConfig[idx].device) ||
            devIsEqual(duetConfig[idx].device, deviceRuntime))
        {
            slot = idx
            break
        }
    }

    if (slot)
    {
        if (devIsNull(duetConfig[slot].device))
        {
            duetConfig[slot].device = deviceRuntime
            rebuild_event()
        }
    }
    else
    {
        warn("'Maximum Duet device configs exceeded. Increase limit in ', __FILE__")
    }

    return slot
}

/**
 * Configure IP comms for a duet virtual and trigger device initialisation.
 *
 * This function may be used to configure Duet module IP settings regardless of
 * device state. Application of settings and module reinitialization will be
 * handled in the background at the appropriate time.
 *
 * @param   device     the Duet virtual
 * @param   address    the IP address or hostname
 * @param   port       the port
 */
define_function configDuetIPComms(dev device, char address[], integer port)
{
    stack_var integer slot

    slot = getDuetConfigSlot(device)

    duetConfig[slot].address = address
    duetConfig[slot].port = port
    
    // Make sure the new settings take if the device is already online
    if (device_id(duetConfig[slot].device))
    {
        applyDuetCommsConfig(duetConfig[slot].device)
    }
}

/**
 * Configure serial for a duet virtual and trigger device initialisation.
 *
 * This function may be used to configure Duet module serial settings
 * regardless of device state. Application of settings and module
 * reinitialization will be handled in the background at the appropriate time.
 *
 * @param   device     the Duet virtual
 * @param   baud_rate  the baud rate to use for device communications
 */
define_function configDuetSerialComms(dev device, long baud)
{
    stack_var integer slot

    slot = getDuetConfigSlot(device)

    duetConfig[slot].baud_rate = baud

    // Make sure the new settings take if the device is already online
    if (device_id(duetConfig[slot].device))
    {
        applyDuetCommsConfig(duetConfig[slot].device)
    }
}

/**
 * Configure IP comms for a duet virtual and trigger device initialisation.
 *
 * This function may be used to configure Duet module auth settings regardless
 * of device state. Application of settings and module reinitialization will be
 * handled in the background at the appropriate time.
 *
 * @param   device     the Duet virtual
 * @param   user_name  the auth user name (if required, otherwise blank)
 * @param   password   the auth password (if required, otherwise blank)
 */
define_function configDuetAuth(dev device, char user_name[], char password[])
{
    stack_var integer slot

    slot = getDuetConfigSlot(device)

    duetConfig[slot].user_name = user_name
    duetConfig[slot].password = password

    // Make sure the new settings take if the device is already online
    if (device_id(duetConfig[slot].device))
    {
        applyDuetCommsConfig(duetConfig[slot].device)
    }
}

/**
 * Applies the current Duet IP device settings to the parsed device slot.
 *
 * @param   device       the device to apply saved setting to
 */
define_function applyDuetCommsConfig(dev device)
{
    stack_var integer idx
    stack_var integer slot
    stack_var DuetCommsProperties config
    stack_var dev deviceRuntime

    deviceRuntime = device
    devRuntimeAddress(deviceRuntime)

    for (idx = 1; idx <= max_length_array(duetConfig); idx++)
    {
        if (devIsEqual(duetConfig[idx].device, deviceRuntime))
        {
            slot = idx;
        }
    }
    
    if (!slot)
    {
        error("'No config saved for ', devToString(deviceRuntime)")
        return
    }
    
    config = duetConfig[slot]
    setProperty(config.device, 'IP_Address', config.address)
    setProperty(config.device, 'Port', itoa(config.port))
    setProperty(config.device, 'Baud_Rate', itoa(config.baud_rate))
    setProperty(config.device, 'User_Name', config.user_name)
    setProperty(config.device, 'Password', config.password)
    reinitialize(config.device)
}


DEFINE_EVENT

data_event[duetConfig[1].device]
data_event[duetConfig[2].device]
data_event[duetConfig[3].device]
data_event[duetConfig[4].device]
data_event[duetConfig[5].device]
{
    online: applyDuetCommsConfig(data.device)
}

#end_if
