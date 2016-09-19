PROGRAM_NAME='log'


#if_not_defined __LOG__
#define __LOG__

define_function log(integer level, char prefix[], char message[])
{
    if (prefix)
    {
        amx_log(level, "'[', prefix, '] ', message")
    }
    else
    {
        amx_log(level, message)
    }
}

define_function debug(char message[])
{
    log(AMX_DEBUG, 'DEBUG', message)
}

define_function info(char message[])
{
    log(AMX_INFO, 'INFO', message)
}

define_function warn(char message[])
{
    log(AMX_WARNING, 'WARN', message)
}

define_function error(char message[])
{
    log(AMX_ERROR, 'ERROR', message)
}

#end_if
