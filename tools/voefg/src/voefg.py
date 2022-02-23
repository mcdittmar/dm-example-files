#!/usr/bin/env python
#
#
# Imports
import sys
import os
from collections import OrderedDict
from pyvodm.model.builders import DocBuilder
from pyvodm.document.writers import VOTWriter
from pyvodm.document.writers import XMLWriter
from pyvodm.utils import *


verbose = 0
toolname = 'voefg'
version = '1.0'

tool_paritems = ( "infile",
                  "template",
                  "outdir",
                  "outfile",
                  "format",
                  "cube",
                  "ds",
                  "coords",
                  "meas",
                  "trans",
                  "ivoa",
                  "clobber",
                  "verbose")

def main():
  """
  Utility tool to generate annotated serializations of data files,
  mapping the file content to various IVOA Data Models.

  The tool uses the CIAO parameter interface to define/control the input 
  argument set.  Use the CIAO 'plist' command to view them.

  Primary Arguments
  -----------------

    infile  : string
              File(s) to annotate.  Each file will be processed according to
              the specified tempate.
    template: string
              Instance Template (ModelMap) providing the mapping of file content
              to IVOA data models.  Defines the output.
    outdir  : string
              Location to put the output files.
    outfile : string
              Output file name (only useful for singluar input).
              '-' will auto-generate the output file names
    format  : string
              Serialization format.
                'vot'   - Produces structured VOTable output
                'avot'  - Produces annotated VOTable output
                           * VO-DML/Mapping syntax referenceing VOTable elements
                'xml'   - Produces XML output

  Primary Arguments
  -----------------
    <model> : Pointers to supported data model descriptions (VO-DML/XML format)

  """
  try:
    # Load tool parameters
    inpars = load_params( "voefg", sys.argv )
  except Exception as ex:
    handle_errors( toolname, ex )

  # set global verbose variable
  verbose = inpars["verbose"]

  if verbose > 0:
    print_params( inpars )

  # Instantiate a DocBuilder
  builder = DocBuilder()

  # Load supported models
  if verbose > 0:
    print("Load supported models:")

  for tag in ["cube", "ds", "coords", "meas", "trans", "ivoa" ]:
    if verbose > 1:
      print( "  model - " + tag )
    try:
      builder.add_model( inpars[ tag ] )
    except Exception as ex:
      handle_errors( toolname, ex )

  # Load instance template
  if verbose > 0:
    print("\nLoad Instance Template:")
  try:
    builder.add_instance_map( inpars[ "template" ] )
  except Exception as ex:
    handle_errors( toolname, ex )

  # Build stack of files to process
  try:
    ifiles = stk_build( inpars[ "infile" ] )
  except Exception as ex:
    print( "Problem building input stack." )
    handle_errors( toolname, ex )

  # Set default block number, of input file to process
  blkno = 1

  # Process files
  if verbose > 0:
    print("\nProcess Files:")

  for infile in ifiles:

    # Check for user-specified block number
    filterndx = infile.find('[')
    if filterndx != -1:
      blkno = infile[filterndx+1:-1]
      item = infile.split('[')[0] # remove any filter syntax
      infile = item

    # Create output filename.
    if ( inpars["outfile"] == "-"):
      ofile = _create_output_filename( inpars["outdir"], infile, inpars["format"] )
    else:
      ofile = inpars["outdir"] + inpars["outfile"]
  
    # Check clobber output file.
    _check_clobber( ofile, inpars["clobber"] )
    
    # Process each file of the input stack
    try:
      if verbose > 1:
        print( "  process file: " + infile)
  
      # Build the Document
      doc = builder.process( infile, blkno )
  
      if verbose > 1:
        print ("  write file: " + ofile)
  
    # Write doc to file
      if inpars["format"] == "xxx":
        fh = open( ofile, 'w' )
        fh.write( str(doc) )
        fh.close()
      elif inpars["format"] == "vot":
        vot = VOTWriter( ofile )
        vot.write( doc )
      elif inpars["format"] == "avot":
        vot = VOTWriter( ofile )
        vot.set_annotation( "vodml" ) # VODML-Mapping syntax
        vot.write( doc )
      elif inpars["format"] == "xml":
        xml = XMLWriter( ofile )
        xml.write( doc )
      else:
        raise ValueError("Problem writing output file, format '{0}' unsupported.\n".format(inpars["format"]) )
  
    # Error handling.
    except Exception as ex:
      handle_errors( toolname, ex )
  
  if verbose > 0:
    print("\nDone.")


# ================================================================================
# Load and validate parameters
#
def load_params( tool, argv=None ):
  """
  Loads and validates tool parameter file contents.

  Parameters
  ----------

    tool : string
           a tool name, associated with a parameter file 
    argv : array_like
           command line arguments, if any

  Returns
  --------
 
   pars : Ordered dictionary
          dictionary of the parameter key-value pairs 


  Raises
  --------

  TypeError  : 
               invalid function argument error 

  IOError    :
               missing parameter

  ValueError :
               parameter validation error

  """

  # Get tool parameters
  try:
    pars = get_params( tool, argv )
  except Exception as e:
    raise(e)

  # validate parameter set
  keylist = list(pars.keys())
  for item in tool_paritems:
    if item not in keylist:
      raise IOError("missing expected parameter, '{0}'".format(item))

  # validate certain parameter values
  try:
    # Infile: must be valid file or stack
    validate_file_param( pars, "infile" )
    
    # Outdir: must be valid directory 
    validate_dir_param( pars, "outdir" )

    # Template: must be an existing file
    validate_file_param( pars, "template" )

    # Clobber: turn into boolean
    fix_bool_param( pars, "clobber" )

  except Exception as e:
    raise(e)

  return pars


# ================================================================================
#
def handle_errors( toolname, ex ):
  """ 
  Method to convert underlying error messages to standard format
  and content appropriate for return from this tool.

  Parameters
  ----------

    toolname: string
              Tool name, for use in output message.
    ex      : Exception 
              Instance of exception whose message is to be 'fixed'.

  Returns
  --------

    msg     : string
              Translated error message. CXC standard format.
              Unrecognized exception strings get special handling.
  """
  msg = None # default to return original string.

  tstr = "{0} ({1}): ".format(toolname, version)
  emsg = str(ex)

  if ( type(ex) is IOError ):
    if ( emsg.find("can\'t find parameter") != -1 ):
      msg = tstr + "ERROR, " + emsg
    elif ( emsg.find("Could not execute paramopen") != -1 ):
      msg = tstr + "ERROR, problem loading parameters."
    elif ( emsg.find("file does not exist") != -1 ):
      msg = tstr + "ERROR, " + emsg
    elif ( emsg.find("Failed to open file") != -1 ):
      msg = tstr + "ERROR, " + emsg
    elif ( (emsg.find("Could not create file") != -1) and (emsg.find("it exists and clobber is False.") != -1) ):
      msg = tstr + "ERROR, " + emsg
    elif ( emsg.find("Source and target are the same") != -1 ):
      msg = tstr + "ERROR, " + emsg
    elif (emsg.find("No such file or directory") != -1 ):
      msg = tstr + "ERROR, " + emsg
    elif (emsg.find("Problem opening Model description file") != -1 ):
      msg = tstr + "ERROR, " + emsg
  elif ( type(ex) is ValueError ):
    msg = tstr + "ERROR, " + emsg
  elif ( type(ex) is RuntimeError ):
    if ( emsg.find("key not found in file") != -1 ):
      msg = tstr + "WARNING, " + emsg
    elif ( emsg.find("column not found in file") != -1 ):
      msg = tstr + "WARNING, " + emsg
  else:
    print("MCD TEMP: unrecognized exception type")

  if msg is None:
    msg = tstr + "ERROR, Unknown {0} exception; {1}".format(ex.__class__.__name__, str(ex))

  if (msg.find("WARNING") != -1 ):
    sys.stderr.write( msg + "\n" )
  else:
    error_exit( msg )


# ================================================================================
#
def error_exit( msg ):
  """
  Prints message to stderr, and exits tool with error status.

  Parameters
  ----------

    msg     : string
              String containing CXC standard format error message.

  Returns
  --------
    none
  """

  sys.stderr.write( msg + "\n")
  sys.exit(1)

# ================================================================================
def _create_output_filename( outdir, ifile, exten ):
  """
  Generate output filename 

  Parameters
  ----------

    outdir  : string
              Output directory path 
    ifile   : string
              Input file name.. seeds output file name
    exten   : string
              File name extension

  Returns
  ----------
    ofile   : string
              Full name of resulting file.

  """
  # strip any filter syntax off input file
  filterndx = ifile.find('[')
  if filterndx != -1:
    ifile = ifile[:filterndx]

  # get base of input file, without extension
  fname = os.path.basename( ifile )
  ndx = fname.rfind('.')

  if ndx != -1:
    fname = fname[:ndx]

  # combine to generate full output filename
  ofile = outdir + fname + '.' + exten

  return ofile


# ================================================================================
def _check_clobber( fname, clobber=True ):
  """
  Check output file existance, and clobber if indicated.

  Parameters
  ----------
    fname   : string
              Full name of file to check and/or clobber.
    clobber : boolean, optional
              Flag to control overwriting of output file.
                'True'  = overwrite if possible. 
                'False' = do not overwrite.
  """
  if fname.strip() == "":
    raise IOError("'fname' argument value invalid. '{0}'".format(fname) )

  if os.path.exists( fname ):
    if (clobber == False ):
      raise IOError("Could not create file '{0}', it exists and clobber is False.".format(fname))
    else:
      # delete existing file.
      try:
        os.unlink( fname )
      except OSError as oe:
        raise IOError("Could not clobber file '{0}'.".format( fname ) )

# ================================================================================
# Invoke program
#
if __name__ == "__main__":
   main()
