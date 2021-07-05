//////////////////////////////////////////////////////////////////////////////
// nv_c64_util_macs_and_data.asm
// import this file to get all the macros and the data for the 
// nv_c64_util "library"
// The data will be placed in a memory block specified below so after
// importing this file be sure to define a new block for the rest of 
// your program.  Should be used something like this:
//
//   #import "nv_c64_macs_and_data.asm"  // import nv_c64_util
//   *=$1000                             // start memory block for
//                                       // the next code/data

// import the nv_c64_util_data at the default location
// it can go anywhere but this is a good out of the way place
// at the end of BASIC memory
#import "../nv_c64_util/nv_c64_util_default_data.asm"

// import the nv_c64_util macros 
#import "../nv_c64_util/nv_c64_util_macs.asm"


