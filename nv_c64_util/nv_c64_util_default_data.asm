
//////////////////////////////////////////////////////////////////////////////
// nv_c64_util_default_data.asm
// import this file to get all the data for the nv_c64_util "library"
// The data will be placed in a default memory block specified below so after
// importing this file be sure to define a new block for the rest of 
// your program.  Should be used something like this:
//
//   #import "nv_c64_default_data.asm"  // import nv_c64_util
//   *=$1000                             // start memory block for
//                                       // the next code/data
//
// Or, alternatively just import the data directly into your program 
// in a place that works for your program but be sure to import
// the data before importing any of the other nv_* files
//
//   *=$5000
//   #import "nv_c64_util_data.asm"
//
// The default location used here is at the very top of memory.
// it can go anywhere but this is a good out of the way place
// at the end of BASIC memory
#importonce

*=$9C00 "nv_c64_util_data"   
#import "../nv_c64_util/nv_c64_util_data.asm"