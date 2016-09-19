PROGRAM_NAME='devices'


#include 'duet-util.axi'


DEFINE_DEVICE

dvMaster = 0:1:0



DEFINE_MODULE

// Instantiate all device modules here



DEFINE_START

// Use utility methods from duet-util.axi to setup module comms and device auth
