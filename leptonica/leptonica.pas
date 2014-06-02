{*====================================================================*
   Leptonica.pas provides Pascal bindings for liblept
   Author: Malcolm Poole <mgpoole@users.sourceforge.net> 2011
 *====================================================================*}

{*====================================================================*
 -  Copyright (C) 2001 Leptonica.  All rights reserved.
 -  This software is distributed in the hope that it will be
 -  useful, but with NO WARRANTY OF ANY KIND.
 -  No author or distributor accepts responsibility to anyone for the
 -  consequences of using this software, or for whether it serves any
 -  particular purpose or works at all, unless he or she says so in
 -  writing.  Everyone is granted permission to copy, modify and
 -  redistribute this source code, for commercial or non-commercial
 -  purposes, with the following restrictions: (1) the origin of this
 -  source code must not be misrepresented; (2) modified versions must
 -  be plainly marked as such; and (3) this notice may not be removed
 -  or altered from any source or modified source distribution.
 *====================================================================*}

unit leptonica;

{$mode objfpc}{$H+}

interface

const
  LIBLEPT = 'lept';

  ImageFileFormatExtensions: array[0..18] of string = ( 'unknown',
          'bmp',
          'jpg',
          'png',
          'tif',
          'tif',
          'tif',
          'tif',
          'tif',
          'tif',
          'tif',
          'pnm',
          'ps',
          'gif',
          'jp2',
          'webp',
          'pdf',
          'default',
          '' );

      IFF_UNKNOWN        = 0;
      IFF_BMP            = 1;
      IFF_JFIF_JPEG      = 2;
      IFF_PNG            = 3;
      IFF_TIFF           = 4;
      IFF_TIFF_PACKBITS  = 5;
      IFF_TIFF_RLE       = 6;
      IFF_TIFF_G3        = 7;
      IFF_TIFF_G4        = 8;
      IFF_TIFF_LZW       = 9;
      IFF_TIFF_ZIP       = 10;
      IFF_PNM            = 11;
      IFF_PS             = 12;
      IFF_GIF            = 13;
      IFF_JP2            = 14;
      IFF_WEBP           = 15;
      IFF_LPDF           = 16;
      IFF_DEFAULT        = 17;
      IFF_SPIX           = 18;

      REMOVE_CMAP_TO_BINARY     = 0;
      REMOVE_CMAP_TO_GRAYSCALE  = 1;
      REMOVE_CMAP_TO_FULL_COLOR = 2;
      REMOVE_CMAP_BASED_ON_SRC  = 3;

      PIX_CLR                   = $0;
      PIX_SET                   = $1e;
      PIX_SRC                   = $18;
      PIX_DST                   = $14;


type

  PLPix = ^TLPix;
  TLPix = record
     w:             Integer;           // width in pixels
     h:             Integer;           // height in pixels
     d:             Integer;           // depth in bits
     wpl:           Cardinal;          // 32-bit words/line
     refcount:      Cardinal;          // reference count (1 if no clones)
     xres:          Integer;           // image res (ppi) in x direction
                                       // (use 0 if unknown)
     yres:          Integer;           // image res (ppi) in y direction
                                       // (use 0 if unknown)
     informat:      Integer;           // input file format, IFF_*
     text:          PChar;             // text string associated with pix
     colormap:      Pointer;           // to colormap (may be null)
     data:          PCardinal;         // the image data
  end;

  PPLPix = ^PLPix;

  PPLBox = ^PLBox;
  PLBox = ^TLBox;
  TLBox = record
    x:         Longint;
    y:         Longint;
    w:         Longint;
    h:         Longint;
    refcount:  Cardinal; //reference count (1 if no clones)
  end;

 PBoxArray = ^TBoxArray;
 TBoxArray = record
    n:        integer;             // number of box in ptr array
    nalloc:   integer;             // number of box ptrs allocated
    refcount: Cardinal;            // reference count (1 if no clones)
    box:      array of PLBox;      // box ptr array
  end;

 PPBoxArrayArray = ^PBoxArrayArray;
 PBoxArrayArray = ^TBoxArrayArray;
 TBoxArrayArray = record
    n:        integer;             // number of box in ptr array
    nalloc:   integer;             // number of box ptrs allocated
    boxa:      array of PBoxArray; // boxa ptr array
  end;


  PPixArray = ^TPixArray;
  TPixArray = record
    n:       Integer;            // number of Pix in ptr array
    nalloc:  Integer;            // number of Pix ptrs allocated
    refcount:Cardinal;            // reference count (1 if no clones)
    pix:     array of PLPix;           // the array of ptrs to pix
    boxa:    array of TLBox;          // array of boxes
  end;

  PPointArray = ^TPointArray;
  TPointArray = record
    n: Integer;             //* actual number of pts
    nalloc: Integer;        //* size of allocated arrays
    refcount: Integer;      //* reference count (1 if no clones)
    x, y: Array of Single;  //* arrays of floats
  end;


  PNumArray = ^TNumArray;
  TNumArray = record
    nalloc:         Integer;           //* size of allocated number array
    n:              Integer;           //* number of numbers saved
    refcount:       Integer;           //* reference count (1 if no clones)
    startx:         Single;            //* x value assigned to array[0]
    delx:           Single;            //* change in x value as i --> i + 1
    numarray:       array of Single;   //* number array
  end;

  PPta = ^TPta;
  TPta = record
     n:          Integer;             // actual number of pts
     nalloc:     Integer;             // size of allocated arrays
     refcount:   Integer;             // reference count (1 if no clones)
     x, y:       Single;              // arrays of floats
  end;

  PPtaArray = ^TPtaArray;
  TPtaArray = record
     n:          Integer;           // number of pta in ptr array
     nalloc:     Integer;           // number of pta ptrs allocated
     pta:        array of PPta;     // pta ptr array
  end;

  // String array: an array of C strings
  PSArray = ^TSArray;
  TSarray = record
     nalloc:     Integer;           // size of allocated ptr array
     n:          Integer;           // number of strings allocated
     refcount:   Integer;           // reference count (1 if no clones)
     strarray:   array of PChar;    // string array
  end;

  PPixCmap = Pointer;

{*-------------------------------------------------------------------------*
 *                         Access and storage flags                        *
 *-------------------------------------------------------------------------*/
/*
 *  For Pix, Box, Pta and Numa, there are 3 standard methods for handling
 *  the retrieval or insertion of a struct:
 *     (1) direct insertion (Don't do this if there is another handle
 *                           somewhere to this same struct!)
 *     (2) copy (Always safe, sets up a refcount of 1 on the new object.
 *               Can be undesirable if very large, such as an image or
 *               an array of images.)
 *     (3) clone (Makes another handle to the same struct, and bumps the
 *                refcount up by 1.  Safe to do unless you're changing
 *                data through one of the handles but don't want those
 *                changes to be seen by the other handle.)
 *
 *  For Pixa and Boxa, which are structs that hold an array of clonable
 *  structs, there is an additional method:
 *     (4) copy-clone (Makes a new higher-level struct with a refcount
 *                     of 1, but clones all the structs in the array.)
 *
 *  Unlike the other structs, when retrieving a string from an Sarray,
 *  you are allowed to get a handle without a copy or clone (i.e., that
 *  you don't own!).  You must not free or insert such a string!
 *  Specifically, for an Sarray, the copyflag for retrieval is either:
 *         TRUE (or 1 or L_COPY)
 *  or
 *         FALSE (or 0 or L_NOCOPY)
 *  For insertion, the copyflag is either:
 *         TRUE (or 1 or L_COPY)
 *  or
 *         FALSE (or 0 or L_INSERT)
 *  Note that L_COPY is always 1, and L_INSERT and L_NOCOPY are always 0.
 *}
const
    L_INSERT = 0;     // stuff it in; no copy, clone or copy-clone
    L_COPY = 1;       // make/use a copy of the object
    L_CLONE = 2;      // make/use clone (ref count) of the object
    L_COPY_CLONE = 3; // make a new object and fill with with clones
                      // of each object in the array(s)

const
    L_NOCOPY = 0;     // copyflag value in sarrayGetString()

    {*-------------------------------------------------------------------------*
     *                        Graphics pixel setting                           *
     *-------------------------------------------------------------------------*}
const
        L_SET_PIXELS   = 1;            // set all bits in each pixel to 1
        L_CLEAR_PIXELS = 2;            // set all bits in each pixel to 0
        L_FLIP_PIXELS  = 3;            // flip all bits in each pixel

        COLOR_RED       = 0;
        OLOR_GREEN      = 1;
        COLOR_BLUE      = 2;
        L_ALPHA_CHANNEL = 3;


  function pixRead ( filename: PChar ): PLPix; cdecl; external LIBLEPT;
  function pixCreate( w, h, format: Integer ): TLPix; cdecl; external LIBLEPT;
  function pixClone ( pixs: PLPix ): PLPix; cdecl; external LIBLEPT;
  procedure pixDestroy ( pix: PLPix ); cdecl; external LIBLEPT;
  procedure numaDestroy ( pna: PNumArray ); cdecl; external LIBLEPT;
  procedure ptaDestroy ( pta: PPointArray ); cdecl; external LIBLEPT;
  function pixGetInputFormat ( Pix: TLPix ): Integer; cdecl; external LIBLEPT;
  function pixGetXRes ( Pix: PLPix ): Integer; cdecl; external LIBLEPT;
  function pixGetYRes ( Pix: PLPix ): Integer; cdecl; external LIBLEPT;
  function pixSetResolution ( pix: PLPix; xres, yres: Integer ): Integer; cdecl; external LIBLEPT;
  function pixWriteStream( fp: Pointer; pix: PLPix; imagefileformat: Integer): Integer; cdecl; external LIBLEPT;
  function pixRotate90 (pixs: PLPix; rotatedirection: Integer ): PLPix; cdecl; external LIBLEPT;
  function pixSobelEdgeFilter ( pixs: PLPix; orientflag: Integer ): PLPix;  cdecl; external LIBLEPT;
  function ptaWriteStream ( fp: pointer; pta: PPointArray; nktype: integer ): integer; cdecl; external LIBLEPT;
  function ptaWrite (  filename: PChar; pta: PPointArray; nktype: integer ): integer; cdecl; external LIBLEPT;
  function pixGetDimensions( pix: PLPix; pw, ph, pd: PInteger): Integer; cdecl; external LIBLEPT;
  function pixScale( pix: PLPix; pw, ph: Single): PLPix; cdecl; external LIBLEPT;
  function pixScaleSmooth( pix: PLPix; pw, ph: Single): PLPix; cdecl; external LIBLEPT;
  function pixGetDepth( pix: PLPix): Integer; cdecl; external LIBLEPT;
  function boxaaCreate(n: Integer):PBoxArrayArray; cdecl; external LIBLEPT;
  procedure boxaaDestroy(pbaa: PPBoxArrayArray); cdecl; external LIBLEPT;

 {
  function pixScaleToSize( pix: PLPix; wd, hd: Integer): PLPix;
  function pixScaleBySampling( pix: PLPix; pw, ph: Single): PLPix;
  function pixScaleRGBToGrayFast( pix: PLPix; pw, ph: Single): PLPix;
  function pixReadHeader( filename: PChar; pformat, pw, ph, pbps, pspp, piscmap: PInteger): Integer;
  function findFileFormat( filename: PChar; pformat: PInteger): Integer;
  function findFileFormatBuffer(buf: PByte ; pformat: PInteger): Integer;
  function pixReadMem(data: PByte; size: PCardinal): PLPix;
  function pixReadHeaderMem( data: PByte; size: PCardinal; pformat, pw, ph, pbps, pspp, piscmap: PInteger): Integer;
  function pixDeskew( pixs: PLPix; redsearch: Integer ): PLPix;
  function pixDeskewLocal( pixs: PLPix; nslices, redsweep, redsearch: Integer; sweeprange, sweepdelta, minbsdelta: Single): PLPix;
  function pixDeskewGeneral( pixs: PLPix; redsweep: integer; sweeprange, sweepdelta: Single;
                           redsearch, thresh: Integer; pangle, pconf: PSingle ): PLPix;
 }


 {*!
  *  pixGetText()
  *
  *      Input:  pix
  *      Return: ptr to existing text string
  *
  *  Notes:
  *      (1) The text string belongs to the pix.  The caller must
  *          NOT free it!
  *}
 function pixGetText( pix: PLPix ): PChar; cdecl; external LIBLEPT;


{*!
 *  pixSetText()
 *
 *      Input:  pix
 *              textstring (can be null)
 *      Return: 0 if OK, 1 on error
 *
 *  Notes:
 *      (1) This removes any existing textstring and puts a copy of
 *          the input textstring there.
 *}
function pixSetText( pix: PLPix; textstring: PChar ): Integer; cdecl; external LIBLEPT;

{*!
 *  pixAddText()
 *
 *      Input:  pix
 *              textstring
 *      Return: 0 if OK, 1 on error
 *
 *  Notes:
 *      (1) This adds the new textstring to any existing text.
 *      (2) Either or both the existing text and the new text
 *          string can be null.
 *}
function pixAddText( pix: PLPix; textstring: PChar ): Integer; cdecl; external LIBLEPT;



 {*!
  *  pixRotate90()
  *
  *      Input:  pixs (all depths)
  *              direction (1 = clockwise,  -1 = counter-clockwise)
  *      Return: pixd, or null on error
  *
  *  Notes:
  *      (1) This does a 90 degree rotation of the image about the center,
  *          either cw or ccw, returning a new pix.
  *      (2) The direction must be either 1 (cw) or -1 (ccw).
  *}
 function pixRotate90 	( pixs: TLPix; direction: Integer ): TLPix; cdecl; external LIBLEPT;

 {*!
 *  pixRotate180()
 *
 *      Input:  pixd  (<optional>; can be null, equal to pixs,
 *                     or different from pixs)
 *              pixs (all depths)
 *      Return: pixd, or null on error
 *
 *  Notes:
 *      (1) This does a 180 rotation of the image about the center,
 *          which is equivalent to a left-right flip about a vertical
 *          line through the image center, followed by a top-bottom
 *          flip about a horizontal line through the image center.
 *      (2) There are 3 cases for input:
 *          (a) pixd == null (creates a new pixd)
 *          (b) pixd == pixs (in-place operation)
 *          (c) pixd != pixs (existing pixd)
 *      (3) For clarity, use these three patterns, respectively:
 *          (a) pixd = pixRotate180(NULL, pixs);
 *          (b) pixRotate180(pixs, pixs);
 *          (c) pixRotate180(pixd, pixs);
 *}
function pixRotate180( pixd, pixs: PLPix): PLPix; cdecl; external LIBLEPT;


{*!
 *  pixScaleToSize()
 *
 *      Input:  pixs (1, 2, 4, 8, 16 and 32 bpp)
 *              wd  (target width; use 0 if using height as target)
 *              hd  (target height; use 0 if using width as target)
 *      Return: pixd, or null on error
 *
 *  Notes:
 *      (1) The guarantees that the output scaled image has the
 *          dimension(s) you specify.
 *           - To specify the width with isotropic scaling, set @hd = 0.
 *           - To specify the height with isotropic scaling, set @wd = 0.
 *           - If both @wd and @hd are specified, the image is scaled
 *             (in general, anisotropically) to that size.
 *           - It is an error to set both @wd and @hd to 0.
 *}
 function pixScaleToSize( pix: PLPix; wd, hd: Integer): PLPix; cdecl; external LIBLEPT;


  {*------------------------------------------------------------------*
   *                  Scaling by closest pixel sampling               *
   *------------------------------------------------------------------*/
  /*!
   *  pixScaleBySampling()
   *
   *      Input:  pixs (1, 2, 4, 8, 16, 32 bpp)
   *              scalex, scaley
   *      Return: pixd, or null on error
   *
   *  Notes:
   *      (1) This function samples from the source without
   *          filtering.  As a result, aliasing will occur for
   *          subsampling (@scalex and/or @scaley < 1.0).
   *      (2) If @scalex == 1.0 and @scaley == 1.0, returns a copy.
   *}
  function pixScaleBySampling( pix: PLPix; pw, ph: Single): PLPix; cdecl; external LIBLEPT;

{*------------------------------------------------------------------*
 *            Fast integer factor subsampling RGB to gray           *
 *------------------------------------------------------------------*/
/*!
 *  pixScaleRGBToGrayFast()
 *
 *      Input:  pixs (32 bpp rgb)
 *              factor (integer reduction factor >= 1)
 *              color (one of COLOR_RED, COLOR_GREEN, COLOR_BLUE)
 *      Return: pixd (8 bpp), or null on error
 *
 *  Notes:
 *      (1) This does simultaneous subsampling by an integer factor and
 *          extraction of the color from the RGB pix.
 *      (2) It is designed for maximum speed, and is used for quickly
 *          generating a downsized grayscale image from a higher resolution
 *          RGB image.  This would typically be used for image analysis.
 *      (3) The standard color byte order (RGBA) is assumed.
 *}
  function pixScaleRGBToGrayFast( pix: PLPix; factor, color: Longint ): PLPix; cdecl; external LIBLEPT;

 { *  pixReadHeader()
   *
   *      Input:  filename (with full pathname or in local directory)
   *              &format (<optional return> file format)
   *              &w, &h (<optional returns> width and height)
   *              &bps <optional return> bits/sample
   *              &spp <optional return> samples/pixel (1, 3 or 4)
   *              &iscmap (<optional return> 1 if cmap exists; 0 otherwise)
   *      Return: 0 if OK, 1 on error }
  function pixReadHeader( filename: PChar; pformat, pw, ph, pbps, pspp, piscmap: PInteger): Integer; cdecl; external LIBLEPT;

{*  findFileFormat()
 *
 *      Input:  filename
 *              &format (<return>)
 *      Return: 0 if OK, 1 on error or if format is not recognized }
  function findFileFormat( filename: PChar; pformat: PInteger): Integer; cdecl; external LIBLEPT;

{*  findFileFormatBuffer()
 *
 *      Input:  byte buffer (at least 12 bytes in size; we can't check)
 *              &format (<return>)
 *      Return: 0 if OK, 1 on error or if format is not recognized
 *
 *  Notes:
 *      (1) This determines the file format from the first 12 bytes in
 *          the compressed data stream, which are stored in memory.
 *      (2) For tiff files, this returns IFF_TIFF.  The specific tiff
 *          compression is then determined using findTiffCompression().}
  function findFileFormatBuffer(buf: PByte ; pformat: PInteger): Integer; cdecl; external LIBLEPT;

{*  pixReadMem()
 *
 *      Input:  data (const; encoded)
 *              datasize (size of data)
 *      Return: pix, or null on error
 *
 *  Notes:
 *      (1) This is a variation of pixReadStream(), where the data is read
 *          from a memory buffer rather than a file.
 *      (2) On windows, this will only read tiff formatted files from
 *          memory.  For other formats, it requires fmemopen(3).
 *          Attempts to read those formats will fail at runtime.
 *      (3) findFileFormatBuffer() requires up to 8 bytes to decide on
 *          the format.  That determines the constraint here.}
  function pixReadMem(data: PByte; size: Cardinal): PLPix; cdecl; external LIBLEPT;

  { *  pixReadHeaderMem()
   *
   *      Input:  data (const; encoded)
   *              datasize (size of data)
   *              &format (<optional return> file format)
   *              &w, &h (<optional returns> width and height)
   *              &bps <optional return> bits/sample
   *              &spp <optional return> samples/pixel (1, 3 or 4)
   *              &iscmap (<optional return> 1 if cmap exists; 0 otherwise)
   *      Return: 0 if OK, 1 on error }
  function pixReadHeaderMem( data: PByte; size: Cardinal; pformat, pw, ph, pbps, pspp, piscmap: PInteger): Integer; cdecl; external LIBLEPT;

  {/*---------------------------------------------------------------------*
 *               Projective transform to remove local skew             *
 *---------------------------------------------------------------------*/
/*!
 *  pixDeskewLocal()
 *
 *      Input:  pixs
 *              nslices  (the number of horizontal overlapping slices; must
 *                  be larger than 1 and not exceed 20; use 0 for default)
 *              redsweep (sweep reduction factor: 1, 2, 4 or 8;
 *                        use 0 for default value)
 *              redsearch (search reduction factor: 1, 2, 4 or 8, and
 *                         not larger than redsweep; use 0 for default value)
 *              sweeprange (half the full range, assumed about 0; in degrees;
 *                          use 0.0 for default value)
 *              sweepdelta (angle increment of sweep; in degrees;
 *                          use 0.0 for default value)
 *              minbsdelta (min binary search increment angle; in degrees;
 *                          use 0.0 for default value)
 *      Return: pixd, or null on error
 *
 *  Notes:
 *      (1) This function allows deskew of a page whose skew changes
 *          approximately linearly with vertical position.  It uses
 *          a projective tranform that in effect does a differential
 *          shear about the LHS of the page, and makes all text lines
 *          horizontal.
 *      (2) The origin of the keystoning can be either a cheap document
 *          feeder that rotates the page as it is passed through, or a
 *          camera image taken from either the left or right side
 *          of the vertical.
 *      (3) The image transformation is a projective warping,
 *          not a rotation.  Apart from this function, the text lines
 *          must be properly aligned vertically with respect to each
 *          other.  This can be done by pre-processing the page; e.g.,
 *          by rotating or horizontally shearing it.
 *          Typically, this can be achieved by vertically aligning
 *          the page edge.}
  function pixDeskewLocal( pixs: PLPix; nslices, redsweep, redsearch: Integer; sweeprange, sweepdelta, minbsdelta: Single): PLPix; cdecl; external LIBLEPT;

{*---------------------------------------------------------------------*
 *                    Locate text baselines in an image                *
 *---------------------------------------------------------------------*}
{*!
 *  pixFindBaselines()
 *
 *      Input:  pixs (1 bpp)
 *              &pta (<optional return> pairs of pts corresponding to
 *                    approx. ends of each text line)
 *              debug (usually 0; set to 1 for debugging output)
 *      Return: na (of baseline y values), or null on error
 *
 *  Notes:
 *      (1) Input binary image must have text lines already aligned
 *          horizontally.  This can be done by either rotating the
 *          image with pixDeskew(), or, if a projective transform
 *          is required, by doing pixDeskewLocal() first.
 *      (2) Input null for &pta if you don't want this returned.
 *          The pta will come in pairs of points (left and right end
 *          of each baseline).
 *      (3) Caution: this will not work properly on text with multiple
 *          columns, where the lines are not aligned between columns.
 *          If there are multiple columns, they should be extracted
 *          separately before finding the baselines.
 *      (4) This function constructs different types of output
 *          for baselines; namely, a set of raster line values and
 *          a set of end points of each baseline.
 *      (5) This function was designed to handle short and long text lines
 *          without using dangerous thresholds on the peak heights.  It does
 *          this by combining the differential signal with a morphological
 *          analysis of the locations of the text lines.  One can also
 *          combine this data to normalize the peak heights, by weighting
 *          the differential signal in the region of each baseline
 *          by the inverse of the width of the text line found there.
 *      (6) There are various debug sections that can be turned on
 *          with the debug flag.
 }
   function pixFindBaselines( pixs: PLPix; ppta: PPointArray; debug: Integer = 0): PNumArray; cdecl; external LIBLEPT;

{*------------------------------------------------------------------*
 *                     Top level page segmentation                  *
 *------------------------------------------------------------------*/
/*!
 *  pixGetRegionsBinary()
 *
 *      Input:  pixs (1 bpp, assumed to be 300 to 400 ppi)
 *              &pixhm (<optional return> halftone mask)
 *              &pixtm (<optional return> textline mask)
 *              &pixtb (<optional return> textblock mask)
 *              debug (flag: set to 1 for debug output)
 *      Return: 0 if OK, 1 on error
 *
 *  Notes:
 *      (1) It is best to deskew the image before segmenting.
 *      (2) The debug flag enables a number of outputs.  These
 *          are included to show how to generate and save/display
 *          these results.
 *}
   function pixGetRegionsBinary ( pixs: PLPix; ppixhm, ppixtm, ppixtb: PPLPix; debug: Integer=0): Integer; cdecl; external LIBLEPT;

{/*------------------------------------------------------------------*
 *                    Halftone region extraction                    *
 *------------------------------------------------------------------*/
/*!
 *  pixGenHalftoneMask()
 *
 *      Input:  pixs (1 bpp, assumed to be 150 to 200 ppi)
 *              &pixtext (<optional return> text part of pixs)
 *              &htfound (<optional return> 1 if the mask is not empty)
 *              debug (flag: 1 for debug output)
 *      Return: pixd (halftone mask), or null on error
 *}
function pixGenHalftoneMask( pixs: PLPix; ppixtext: PPLPix; phtfound: PInteger; debug: Integer = 0): PLPix; cdecl; external LIBLEPT;

{*--------------------------------------------------------------------*
 *                 Thresholding from 32 bpp rgb to 1 bpp              *
 *--------------------------------------------------------------------*/
/*!
 *  pixGenerateMaskByBand32()
 *
 *      Input:  pixs (32 bpp)
 *              refval (reference rgb value)
 *              delm (max amount below the ref value for any component)
 *              delp (max amount above the ref value for any component)
 *      Return: pixd (1 bpp), or null on error
 *
 *  Notes:
 *      (1) Generates a 1 bpp mask pixd, the same size as pixs, where
 *          the fg pixels in the mask are those where each component
 *          is within -delm to +delp of the reference value.
 *}
function pixGenerateMaskByBand32( pixs: PLPix; refval: Cardinal; delm, delp: Longint): PLPix; cdecl; external LIBLEPT;

{*!
 *  pixGenerateMaskByBand()
 *
 *      Input:  pixs (4 or 8 bpp, or colormapped)
 *              lower, upper (two pixel values from which a range, either
 *                            between (inband) or outside of (!inband),
 *                            determines which pixels in pixs cause us to
 *                            set a 1 in the dest mask)
 *              inband (1 for finding pixels in [lower, upper];
 *                      0 for finding pixels in [0, lower) union (upper, 255])
 *              usecmap (1 to retain cmap values; 0 to convert to gray)
 *      Return: pixd (1 bpp), or null on error
 *
 *  Notes:
 *      (1) Generates a 1 bpp mask pixd, the same size as pixs, where
 *          the fg pixels in the mask are those either within the specified
 *          band (for inband == 1) or outside the specified band
 *          (for inband == 0).
 *      (2) If pixs is colormapped, @usecmap determines if the colormap
 *          values are used, or if the colormap is removed to gray and
 *          the gray values are used.  For the latter, it generates
 *          an approximate grayscale value for each pixel, and then looks
 *          for gray pixels with the value @val.
 *}
function pixGenerateMaskByBand( pixs: PLPix; lower, upper, inband, usecmap: Longint): PLPix; cdecl; external LIBLEPT;

{*--------------------------------------------------------------------*
 *       Generate a binary mask from pixels of particular value(s)    *
 *--------------------------------------------------------------------*/
/*!
 *  pixGenerateMaskByValue()
 *
 *      Input:  pixs (4 or 8 bpp, or colormapped)
 *              val (of pixels for which we set 1 in dest)
 *              usecmap (1 to retain cmap values; 0 to convert to gray)
 *      Return: pixd (1 bpp), or null on error
 *
 *  Notes:
 *      (1) @val is the gray value of the pixels that we are selecting.
 *      (2) If pixs is colormapped, @usecmap determines if the colormap
 *          values are used, or if the colormap is removed to gray and
 *          the gray values are used.  For the latter, it generates
 *          an approximate grayscale value for each pixel, and then looks
 *          for gray pixels with the value @val.
 *}
function pixGenerateMaskByValue( pixs: PLPix; val, usecmap: Longint ): PLPix; cdecl; external LIBLEPT;

{*-------------------------------------------------------------*
 *               Conversion from colormapped pix               *
 *-------------------------------------------------------------*/
/*!
 *  pixRemoveColormap()
 *
 *      Input:  pixs (see restrictions below)
 *              type (REMOVE_CMAP_TO_BINARY,
 *                    REMOVE_CMAP_TO_GRAYSCALE,
 *                    REMOVE_CMAP_TO_FULL_COLOR,
 *                    REMOVE_CMAP_BASED_ON_SRC)
 *      Return: new pix, or null on error
 *
 *  Notes:
 *      (1) If there is no colormap, a clone is returned.
 *      (2) Otherwise, the input pixs is restricted to 1, 2, 4 or 8 bpp.
 *      (3) Use REMOVE_CMAP_TO_BINARY only on 1 bpp pix.
 *      (4) For grayscale conversion from RGB, use a weighted average
 *          of RGB values, and always return an 8 bpp pix, regardless
 *          of whether the input pixs depth is 2, 4 or 8 bpp.
 *}
function pixRemoveColormap( pixs: PLPix; newtype: Longint ): PLPix; cdecl; external LIBLEPT;

{*-------------------------------------------------------------*
 *            Conversion from RGB color to grayscale           *
 *-------------------------------------------------------------*/
/*!
 *  pixConvertRGBToLuminance()
 *
 *      Input:  pix (32 bpp RGB)
 *      Return: 8 bpp pix, or null on error
 *
 *  Notes:
 *      (1) Use a standard luminance conversion.
 *}
function pixConvertRGBToLuminance( pixs: PLPix ): PLPix; cdecl; external LIBLEPT;

{*!
 *  pixConvertRGBToGray()
 *
 *      Input:  pix (32 bpp RGB)
 *              rwt, gwt, bwt  (non-negative; these should add to 1.0,
 *                              or use 0.0 for default)
 *      Return: 8 bpp pix, or null on error
 *
 *  Notes:
 *      (1) Use a weighted average of the RGB values.
 *}
function pixConvertRGBToGray( pixs: PLPix; rwt, gwt, bwt: Single ): PLPix; cdecl; external LIBLEPT;

{*!
 *  pixConvertRGBToGrayFast()
 *
 *      Input:  pix (32 bpp RGB)
 *      Return: 8 bpp pix, or null on error
 *
 *  Notes:
 *      (1) This function should be used if speed of conversion
 *          is paramount, and the green channel can be used as
 *          a fair representative of the RGB intensity.  It is
 *          several times faster than pixConvertRGBToGray().
 *      (2) To combine RGB to gray conversion with subsampling,
 *          use pixScaleRGBToGrayFast() instead.
 *}
function pixConvertRGBToGrayFast( pixs: PLPix ): PLPix; cdecl; external LIBLEPT;

{*---------------------------------------------------------------------------*
 *                    Top-level conversion to 32 bpp                         *
 *---------------------------------------------------------------------------*/
/*!
 *  pixConvertTo32()
 *
 *      Input:  pixs (1, 2, 4, 8, 16 or 32 bpp)
 *      Return: pixd (32 bpp), or null on error
 *
 *  Usage: Top-level function, with simple default values for unpacking.
 *      1 bpp:  val0 = 255, val1 = 0
 *              and then replication into R, G and B components
 *      2 bpp:  if colormapped, use the colormap values; otherwise,
 *              use val0 = 0, val1 = 0x55, val2 = 0xaa, val3 = 255
 *              and replicate gray into R, G and B components
 *      4 bpp:  if colormapped, use the colormap values; otherwise,
 *              replicate 2 nybs into a byte, and then into R,G,B components
 *      8 bpp:  if colormapped, use the colormap values; otherwise,
 *              replicate gray values into R, G and B components
 *      16 bpp: replicate MSB into R, G and B components
 *      24 bpp: unpack the pixels, maintaining word alignment on each scanline
 *      32 bpp: makes a copy
 *
 *  Notes:
 *      (1) Implicit assumption about RGB component ordering.
 *}
function pixConvertTo32( pixs: PLPix): PLPix; cdecl; external LIBLEPT;

{PIX* pixConvertTo8 	( 	PIX *  	pixs,
		l_int32  	cmapflag
	)    }

function pixConvertTo8( pixs: PLPix; cmpflag: longint ): PLPix; cdecl; external LIBLEPT;

{/*------------------------------------------------------------------*
 *                         Textline extraction                      *
 *------------------------------------------------------------------*/
/*!
 *  pixGenTextlineMask()
 *
 *      Input:  pixs (1 bpp, assumed to be 150 to 200 ppi)
 *              &pixvws (<return> vertical whitespace mask)
 *              &tlfound (<optional return> 1 if the mask is not empty)
 *              debug (flag: 1 for debug output)
 *      Return: pixd (textline mask), or null on error
 *
 *  Notes:
 *      (1) The input pixs should be deskewed.
 *      (2) pixs should have no halftone pixels.
 *      (3) Both the input image and the returned textline mask
 *          are at the same resolution.
 *}
function pixGenTextlineMask( pixs: PLPix; ppixvws: PPLPix; ptlfound: PInteger; debug: Integer = 0): PLPix; cdecl; external LIBLEPT;

{/*------------------------------------------------------------------*
 *       Simple (pixelwise) binarization with fixed threshold       *
 *------------------------------------------------------------------*/
/*!
 *  pixThresholdToBinary()
 *
 *      Input:  pixs (4 or 8 bpp)
 *              threshold value
 *      Return: pixd (1 bpp), or null on error
 *
 *  Notes:
 *      (1) If the source pixel is less than the threshold value,
 *          the dest will be 1; otherwise, it will be 0
 *}
function pixThresholdToBinary( pixs: PLPix; thresh: Integer): PLPix; cdecl; external LIBLEPT;


{
00110 /*-------------------------------------------------------------*
00111  *         Gamma TRC (tone reproduction curve) mapping         *
00112  *-------------------------------------------------------------*/
00113 /*!
00114  *  pixGammaTRC()
00115  *
00116  *      Input:  pixd (<optional> null or equal to pixs)
00117  *              pixs (8 or 32 bpp; or 2, 4 or 8 bpp with colormap)
00118  *              gamma (gamma correction; must be > 0.0)
00119  *              minval  (input value that gives 0 for output; can be < 0)
00120  *              maxval  (input value that gives 255 for output; can be > 255)
00121  *      Return: pixd always
00122  *
00123  *  Notes:
00124  *      (1) pixd must either be null or equal to pixs.
00125  *          For in-place operation, set pixd == pixs:
00126  *             pixGammaTRC(pixs, pixs, ...);
00127  *          To get a new image, set pixd == null:
00128  *             pixd = pixGammaTRC(NULL, pixs, ...);
00129  *      (2) If pixs is colormapped, the colormap is transformed,
00130  *          either in-place or in a copy of pixs.
00131  *      (3) We use a gamma mapping between minval and maxval.
00132  *      (4) If gamma < 1.0, the image will appear darker;
00133  *          if gamma > 1.0, the image will appear lighter;
00134  *      (5) If gamma = 1.0 and minval = 0 and maxval = 255, no
00135  *          enhancement is performed; return a copy unless in-place,
00136  *          in which case this is a no-op.
00137  *      (6) For color images that are not colormapped, the mapping
00138  *          is applied to each component.
00139  *      (7) minval and maxval are not restricted to the interval [0, 255].
00140  *          If minval < 0, an input value of 0 is mapped to a
00141  *          nonzero output.  This will turn black to gray.
00142  *          If maxval > 255, an input value of 255 is mapped to
00143  *          an output value less than 255.  This will turn
00144  *          white (e.g., in the background) to gray.
00145  *      (8) Increasing minval darkens the image.
00146  *      (9) Decreasing maxval bleaches the image.
00147  *      (10) Simultaneously increasing minval and decreasing maxval
00148  *           will darken the image and make the colors more intense;
00149  *           e.g., minval = 50, maxval = 200.
00150  *      (11) See numaGammaTRC() for further examples of use.
00151  */
}
function pixGammaTRC( pixd, pixs: PLPix; gamma: Single; minval, maxval: Integer ):  PLPix; cdecl; external LIBLEPT;



{*!
 *  pixWrite()
 *
 *      Input:  filename
 *              pix
 *              format  (defined in imageio.h)
 *      Return: 0 if OK; 1 on error
 *
 *  Notes:
 *      (1) Open for write using binary mode (with the "b" flag)
 *          to avoid having Windows automatically translate the NL
 *          into CRLF, which corrupts image files.  On non-windows
 *          systems this flag should be ignored, per ISO C90.
 *          Thanks to Dave Bryan for pointing this out.
 *      (2) If the default image format is requested, we use the input format;
 *          if the input format is unknown, a lossless format is assigned.
 *      (3) There are two modes with respect to file naming.
 *          (a) The default code writes to @filename.
 *          (b) If WRITE_AS_NAMED is defined to 0, it's a bit fancier.
 *              Then, if @filename does not have a file extension, one is
 *              automatically appended, depending on the requested format.
 *          The original intent for providing option (b) was to insure
 *          that filenames on Windows have an extension that matches
 *          the image compression.  However, this is not the default.
 *}
function pixWrite( filename: PChar; pix: PLPix; format: Integer): Integer; cdecl; external LIBLEPT;

{*---------------------------------------------------------------------*
 *                            Write to memory                          *
 *---------------------------------------------------------------------*/
/*!
 *  pixWriteMem()
 *
 *      Input:  &data (<return> data of tiff compressed image)
 *              &size (<return> size of returned data)
 *              pix
 *              format  (defined in imageio.h)
 *      Return: 0 if OK, 1 on error
 *
 *  Notes:
 *      (1) On windows, this will only write tiff and PostScript to memory.
 *          For other formats, it requires open_memstream(3).
 *      (2) PostScript output is uncompressed, in hex ascii.
 *          Most printers support level 2 compression (tiff_g4 for 1 bpp,
 *          jpeg for 8 and 32 bpp).
 *}
function pixWriteMem(pdata: Pointer{array of byte}; psize: PInteger; pix: PLPix; imageformat: Integer): Integer; cdecl; external LIBLEPT;

{*-----------------------------------------------------------------------*
 *                       Top-level deskew interfaces                     *
 *-----------------------------------------------------------------------*/
/*!
 *  pixDeskew()
 *
 *      Input:  pixs (any depth)
 *              redsearch (for binary search: reduction factor = 1, 2 or 4;
 *                         use 0 for default)
 *      Return: pixd (deskewed pix), or null on error
 *
 *  Notes:
 *      (1) This binarizes if necessary and finds the skew angle.  If the
 *          angle is large enough and there is sufficient confidence,
 *          it returns a deskewed image; otherwise, it returns a clone.
 *}
function pixDeskew( pixs: PLPix; redsearch: Integer ): PLPix; cdecl; external LIBLEPT;

{*!
 *  pixDeskewGeneral()
 *
 *      Input:  pixs  (any depth)
 *              redsweep  (for linear search: reduction factor = 1, 2 or 4;
 *                         use 0 for default)
 *              sweeprange (in degrees in each direction from 0;
 *                          use 0.0 for default)
 *              sweepdelta (in degrees; use 0.0 for default)
 *              redsearch  (for binary search: reduction factor = 1, 2 or 4;
 *                          use 0 for default;)
 *              thresh (for binarizing the image; use 0 for default)
 *              &angle   (<optional return> angle required to deskew,
 *                        in degrees; use NULL to skip)
 *              &conf    (<optional return> conf value is ratio
 *                        of max/min scores; use NULL to skip)
 *      Return: pixd (deskewed pix), or null on error
 *
 *  Notes:
 *      (1) This binarizes if necessary and finds the skew angle.  If the
 *          angle is large enough and there is sufficient confidence,
 *          it returns a deskewed image; otherwise, it returns a clone.
 *}
function pixDeskewGeneral( pixs: PLPix; redsweep: integer; sweeprange, sweepdelta: Single;
                           redsearch, thresh: Integer; pangle, pconf: PSingle ): PLPix; cdecl; external LIBLEPT;

{*-------------------------------------------------------------*
 *                Extract rectangular region                   *
 *-------------------------------------------------------------*/
/*!
 *  pixClipRectangle()
 *
 *      Input:  pixs
 *              box  (requested clipping region; const)
 *              &boxc (<optional return> actual box of clipped region)
 *      Return: clipped pix, or null on error or if rectangle
 *              doesn't intersect pixs
 *
 *  Notes:
 *
 *  This should be simple, but there are choices to be made.
 *  The box is defined relative to the pix coordinates.  However,
 *  if the box is not contained within the pix, we have two choices:
 *
 *      (1) clip the box to the pix
 *      (2) make a new pix equal to the full box dimensions,
 *          but let rasterop do the clipping and positioning
 *          of the src with respect to the dest
 *
 *  Choice (2) immediately brings up the problem of what pixel values
 *  to use that were not taken from the src.  For example, on a grayscale
 *  image, do you want the pixels not taken from the src to be black
 *  or white or something else?  To implement choice 2, one needs to
 *  specify the color of these extra pixels.
 *
 *  So we adopt (1), and clip the box first, if necessary,
 *  before making the dest pix and doing the rasterop.  But there
 *  is another issue to consider.  If you want to paste the
 *  clipped pix back into pixs, it must be properly aligned, and
 *  it is necessary to use the clipped box for alignment.
 *  Accordingly, this function has a third (optional) argument, which is
 *  the input box clipped to the src pix.
 *}
function pixClipRectangle( pixs: PLPix; box: PLBox; pboxc: PPLBox): PLPix; cdecl; external LIBLEPT;

{*---------------------------------------------------------------------*
 *                  Box creation, destruction and copy                 *
 *---------------------------------------------------------------------*/
/*!
 *  boxCreate()
 *
 *      Input:  x, y, w, h
 *      Return: box, or null on error
 *
 *  Notes:
 *      (1) This clips the box to the +quad.  If no part of the
 *          box is in the +quad, this returns NULL.
 *      (2) We allow you to make a box with w = 0 and/or h = 0.
 *          This does not represent a valid region, but it is useful
 *          as a placeholder in a boxa for which the index of the
 *          box in the boxa is important.  This is an atypical
 *          situation; usually you want to put only valid boxes with
 *          nonzero width and height in a boxa.  If you have a boxa
 *          with invalid boxes, the accessor boxaGetValidBox()
 *          will return NULL on each invalid box.
 *      (3) If you want to create only valid boxes, use boxCreateValid(),
 *          which returns NULL if either w or h is 0.
 *}
function boxCreate(x, y, w, h: longint): PLBox; cdecl; external LIBLEPT;

{*!
 *  boxCreateValid()
 *
 *      Input:  x, y, w, h
 *      Return: box, or null on error
 *
 *  Notes:
 *      (1) This returns NULL if either w = 0 or h = 0.
 *}
function boxCreateValid(x, y, w, h: longint): PLBox; cdecl; external LIBLEPT;

{*!
 *  boxDestroy()
 *
 *      Input:  &box (<will be set to null before returning>)
 *      Return: void
 *
 *  Notes:
 *      (1) Decrements the ref count and, if 0, destroys the box.
 *      (2) Always nulls the input ptr.
 *}
procedure boxDestroy( pbox: PLBox ); cdecl; external LIBLEPT;

{*!
 *  boxGetGeometry()
 *
 *      Input:  box
 *              &x, &y, &w, &h (<optional return>; each can be null)
 *      Return: 0 if OK, 1 on error
 *}
function boxGetGeometry( box: PLBox; px, py, pw, ph: PLongint): LongInt; cdecl; external LIBLEPT;

{*!
 *  boxSetGeometry()
 *
 *      Input:  box
 *              x, y, w, h (use -1 to leave unchanged)
 *      Return: 0 if OK, 1 on error
 *}
 function boxSetGeometry( box: PLBox; px, py, pw, ph: Longint): LongInt; cdecl; external LIBLEPT;


{*-----------------------------------------------------------------------*
 *                Bounding boxes of 4 Connected Components               *
 *-----------------------------------------------------------------------*/
/*!
 *  pixConnComp()
 *
 *      Input:  pixs (1 bpp)
 *              &pixa   (<optional return> pixa of each c.c.)
 *              connectivity (4 or 8)
 *      Return: boxa, or null on error
 *
 *  Notes:
 *      (1) This is the top-level call for getting bounding boxes or
 *          a pixa of the components, and it can be used instead
 *          of either pixConnCompBB() or pixConnCompPixa(), rsp.
 *}
function pixConnComp( pixs: PLPix; ppixa: PPixArray; connectivity: Integer ): PBoxArray; cdecl; external LIBLEPT;

function pixConnCompBB( pixs: PLPix; connectivity: Integer ): PBoxArray; cdecl; external LIBLEPT;

{*!
 *  boxaWrite()
 *
 *      Input:  filename
 *              boxa
 *      Return: 0 if OK, 1 on error
 *}
function boxaWrite(filename: Pchar; boxa: PBoxArray): Integer; cdecl; external LIBLEPT;

function boxaGetCount( boxa: PBoxArray): Integer; cdecl; external LIBLEPT;

procedure boxaDestroy( pboxa: PBoxArray); cdecl; external LIBLEPT;

{*!
 *  boxaGetBox()
 *
 *      Input:  boxa
 *              index  (to the index-th box)
 *              accessflag  (L_COPY or L_CLONE)
 *      Return: box, or null on error
 *}
function boxaGetBox( boxa: PBoxArray; index: Integer; accessflag: Integer): PLBox; cdecl; external LIBLEPT;

{*!
 *  boxaGetBoxGeometry()
 *
 *      Input:  boxa
 *              index  (to the index-th box)
 *              &x, &y, &w, &h (<optional return>; each can be null)
 *      Return: 0 if OK, 1 on error
 *}
function boxaGetBoxGeometry ( boxa: PBoxArray; index: Integer; px, py, pw, ph: PInteger): Integer; cdecl; external LIBLEPT;

{*!
 *  boxaReplaceBox()
 *
 *      Input:  boxa
 *              index  (to the index-th box)
 *              box (insert to replace existing one)
 *      Return: 0 if OK, 1 on error
 *
 *  Notes:
 *      (1) In-place replacement of one box.
 *      (2) The previous box at that location is destroyed.
 *}
function boxaReplaceBox( boxa: PBoxArray; index: Integer; box: PLBox ): Integer; cdecl; external LIBLEPT;

{*!
 *  pixGetData()
 *
 *  Notes:
 *      (1) This gives a new handle for the data.  The data is still
 *          owned by the pix, so do not call FREE() on it.
 *}
function pixGetData( pix: PLPix ): Pointer; cdecl; external LIBLEPT;

function pixGetWpl( pix: PLPix ):Integer; cdecl; external LIBLEPT;

function pixDestroyColormap( pix: PLPix ): Integer; cdecl; external LIBLEPT;

{*!
 *  pixGetWordsInTextlines()
 *
 *      Input:  pixs (1 bpp, 300 ppi)
 *              reduction (1 for full res; 2 for half-res)
 *              minwidth, minheight (of saved components; smaller are discarded)
 *              maxwidth, maxheight (of saved components; larger are discarded)
 *              &boxad (<return> word boxes sorted in textline line order)
 *              &pixad (<return> word images sorted in textline line order)
 *              &naindex (<return> index of textline for each word)
 *      Return: 0 if OK, 1 on error
 *
 *  Notes:
 *      (1) The input should be at a resolution of about 300 ppi.
 *          The word masks can be computed at either 150 ppi or 300 ppi.
 *          For the former, set reduction = 2.
 *      (2) The four size constraints on saved components are all
 *          used at 2x reduction.
 *      (3) The result are word images (and their b.b.), extracted in
 *          textline order, all at 2x reduction, and with a numa giving
 *          the textline index for each word.
 *      (4) The pixa and boxa interfaces should make this type of
 *          application simple to put together.  The steps are:
 *           - generate first estimate of word masks
 *           - get b.b. of these, and remove the small and big ones
 *           - extract pixa of the word mask from these boxes
 *           - extract pixa of the actual word images, using word masks
 *           - sort actual word images in textline order (2d)
 *           - flatten them to a pixa (1d), saving the textline index
 *             for each pix
 *      (5) In an actual application, it may be desirable to pre-filter
 *          the input image to remove large components, to extract
 *          single columns of text, and to deskew them.  For example,
 *          to remove both large components and small noisy components
 *          that can interfere with the statistics used to estimate
 *          parameters for segmenting by words, but still retain text lines,
 *          the following image preprocessing can be done:
 *                Pix *pixt = pixMorphSequence(pixs, "c40.1", 0);
 *                Pix *pixf = pixSelectBySize(pixt, 0, 60, 8,
 *                                     L_SELECT_HEIGHT, L_SELECT_IF_LT, NULL);
 *                pixAnd(pixf, pixf, pixs);  // the filtered image
 *          The closing turns text lines into long blobs, but does not
 *          significantly increase their height.  But if there are many
 *          small connected components in a dense texture, this is likely
 *          to generate tall components that will be eliminated in pixf.
 *}
function pixGetWordsInTextlines( pixs: PLPix; reduction, minwidth, minheight, maxwidth, maxheight: Integer;
                       pboxad: PBoxArray; ppixad: PPixArray; pnai: PNumArray): Integer; cdecl; external LIBLEPT;


{*------------------------------------------------------------------*
 *                       Textblock extraction                       *
 *------------------------------------------------------------------*/
/*!
 *  pixGenTextblockMask()
 *
 *      Input:  pixs (1 bpp, textline mask, assumed to be 150 to 200 ppi)
 *              pixvws (vertical white space mask)
 *              debug (flag: 1 for debug output)
 *      Return: pixd (textblock mask), or null on error
 *
 *  Notes:
 *      (1) Both the input masks (textline and vertical white space) and
 *          the returned textblock mask are at the same resolution.
 *      (2) The result is somewhat noisy, in that small "blocks" of
 *          text may be included.  These can be removed by post-processing,
 *          using, e.g.,
 *             pixSelectBySize(pix, 60, 60, 4, L_SELECT_IF_EITHER,
 *                             L_SELECT_IF_GTE, NULL);
 *}
function pixGenTextblockMask( pixs: PLPix; pixvws: PLPix; debug: Integer): PLPix; cdecl; external LIBLEPT;

{*!
 *  pixGetTextlineCenters()
 *
 *      Input:  pixs (1 bpp)
 *              debugflag (1 for debug output)
 *      Return: ptaa (of center values of textlines)
 *
 *  Notes:
 *      (1) This in general does not have a point for each value
 *          of x, because there will be gaps between words.
 *          It doesn't matter because we will fit a quadratic to the
 *          points that we do have.
 *}
function pixGetTextlineCenters( pixs: PLPix; debugflag: longint): PPtaArray;  cdecl; external LIBLEPT;

{*!
 *  boxaaAddBoxa()
 *
 *      Input:  boxaa
 *              boxa     (to be added)
 *              copyflag  (L_INSERT, L_COPY, L_CLONE)
 *      Return: 0 if OK, 1 on error
 *}
function boxaaAddBoxa(baa: PBoxArrayArray; ba: PBoxArray; copyflag: Integer): Integer; cdecl; external LIBLEPT;

{*!
 *  boxaaGetCount()
 *
 *      Input:  boxaa
 *      Return: count (number of boxa), or 0 if no boxa or on error
 *}
function boxaaGetCount(baa: PBoxArrayArray): Integer; cdecl; external LIBLEPT;

{*!
 *  boxaaGetBoxCount()
 *
 *      Input:  boxaa
 *      Return: count (number of boxes), or 0 if no boxes or on error
 *}
function boxaaGetBoxCount(baa: PBoxArrayArray): Integer; cdecl; external LIBLEPT;

{*!
 *  numaGetFValue()
 *
 *      Input:  na
 *              index (into numa)
 *              &val  (<return> float value; 0.0 on error)
 *      Return: 0 if OK; 1 on error
 *
 *  Notes:
 *      (1) Caller may need to check the function return value to
 *          decide if a 0.0 in the returned ival is valid.
 *}
function numaGetFValue( na: PNumArray; index: Longint; pval: PSingle ): Longint; cdecl; external LIBLEPT;

{*!
 *  numaGetIValue()
 *
 *      Input:  na
 *              index (into numa)
 *              &ival  (<return> integer value; 0 on error)
 *      Return: 0 if OK; 1 on error
 *
 *  Notes:
 *      (1) Caller may need to check the function return value to
 *          decide if a 0 in the returned ival is valid.
 *}
function numaGetIValue( na: PNumArray; index: Longint; pival: PLongint ): Longint; cdecl; external LIBLEPT;

{*!
 *  pixaGetCount()
 *
 *      Input:  pixa
 *      Return: count, or 0 if no pixa
 *}
function pixaGetCount( pixa: PPixArray): Longint; cdecl; external LIBLEPT;

{*!
 *  pixRenderBox()
 *
 *      Input:  pix
 *              box
 *              width  (thickness of box lines)
 *              op  (one of L_SET_PIXELS, L_CLEAR_PIXELS, L_FLIP_PIXELS)
 *      Return: 0 if OK, 1 on error
 *}
function pixRenderBox( pix: PLPix; box: PLBox; width, op: Longint): Longint; cdecl; external LIBLEPT;

{*!
 *  pixRenderBoxArb()
 *
 *      Input:  pix
 *              box
 *              width  (thickness of box lines)
 *              rval, gval, bval
 *      Return: 0 if OK, 1 on error
 *}
function pixRenderBoxArb(pix: PLPix; box: PLBox; width: Longint; rval, gval, bval: word): Longint; cdecl; external LIBLEPT;

{*!
 *  pixRenderBoxBlend()
 *
 *      Input:  pix
 *              box
 *              width  (thickness of box lines)
 *              rval, gval, bval
 *              fract (in [0.0 - 1.0]; complete transparency (no effect)
 *                     if 0.0; no transparency if 1.0)
 *      Return: 0 if OK, 1 on error
 *}
function pixRenderBoxBlend( pix: PLPix; box: PLBox; width: Longint; rval, gval, bval: word; fract: Single): Longint; cdecl; external LIBLEPT;


{*!
 *  pixDisplayWrite()
 *
 *      Input:  pix (1, 2, 4, 8, 16, 32 bpp)
 *              reduction (-1 to reset/erase; 0 to disable;
 *                         otherwise this is a reduction factor)
 *      Return: 0 if OK; 1 on error
 *
 *  Notes:
 *      (1) This defaults to jpeg output for pix that are 32 bpp or
 *          8 bpp without a colormap.  If you want to write all images
 *          losslessly, use format == IFF_PNG in pixDisplayWriteFormat().
 *      (2) See pixDisplayWriteFormat() for usage details.
 *}
function pixDisplayWrite( pixs: PLPix; reduction: longint): Longint; cdecl; external LIBLEPT;

{*!
 *  pixaDisplayRandomCmap()
 *
 *      Input:  pixa (of 1 bpp components, with boxa)
 *              w, h (if set to 0, determines the size from the
 *                    b.b. of the components in pixa)
 *      Return: pix (8 bpp, cmapped, with random colors on the components),
 *              or null on error
 *
 *  Notes:
 *      (1) This uses the boxes to place each pix in the rendered composite.
 *      (2) By default, the background color is: black, cmap index 0.
 *          This can be changed by pixcmapResetColor()
 *}
function pixaDisplayRandomCmap( pixa: PPixArray; w, h: Longint ): PLPix; cdecl; external LIBLEPT;

function pixGetWidth( pix: PLPix ): Longint; cdecl; external LIBLEPT;

function pixSetWidth( pix: PLPix; width: Longint ): Longint; cdecl; external LIBLEPT;

function pixGetHeight( pix: PLPix ): Longint; cdecl; external LIBLEPT;

function pixSetHeight( pix: PLPix; height: Longint ): Longint; cdecl; external LIBLEPT;


function pixGetColormap( pix: PLPix ): PPixCmap; cdecl; external LIBLEPT;

{*!
 *  pixcmapResetColor()
 *
 *      Input:  cmap
 *              index
 *              rval, gval, bval (colormap entry to be reset; each number
 *                                is in range [0, ... 255])
 *      Return: 0 if OK, 1 if not accessable (caller should check)
 *
 *  Notes:
 *      (1) This resets sets the color of an entry that has already
 *          been set and included in the count of colors.
 *}
function pixcmapResetColor( cmap: PPixCmap; index, rval, gval, bval: Longint ): Longint; cdecl; external LIBLEPT;

function saConvertFilesToPdf( sa: PSarray; res: longint; scalefactor: Single; quality: Longint;
                               title, fileout: PChar): Longint; cdecl; external LIBLEPT;

// ===  enhance.c  ===

function pixContrastTRC(pixd, pixs: PLPix; factor: Single): PLPix; cdecl; external LIBLEPT;

function pixUnsharpMasking ( pixs: PLPix; halfwidth: Longint; fract: Single): PLPix; cdecl; external LIBLEPT;

const
        L_JPEG_ENCODE  = 1;
        L_G4_ENCODE    = 2;
        L_FLATE_ENCODE = 3;

 {*
  *  saConvertFilesToPdf()
  *
  *      Input:  sarray (of pathnames for images)
  *              res (input resolution of all images)
  *              scalefactor (scaling factor applied to each image)
  *              type (encoding type (L_JPEG_ENCODE, L_G4_ENCODE,
  *                    L_FLATE_ENCODE, or 0 for default)
  *              quality (used for JPEG only; 0 for default (75))
  *              title (<optional> pdf title; if null, taken from the first
  *                     image filename)
  *              fileout (pdf file of all images)
  *      Return: 0 if OK, 1 on error
  *
  *  Notes:
  *      (1) The images are encoded with G4 if 1 bpp; JPEG if 8 bpp without
  *          colormap and many colors, or 32 bpp; FLATE for anything else.
  *}
function saConvertFilesToPdf 	( sa: PSArray; res: longint; scalefactor: Single;
                                        encoding, quality: longint; title, fileout: PChar): Longint; cdecl; external LIBLEPT;

//  ===  binexpand.c  ==

{*------------------------------------------------------------------*
 *                      Power of 2 expansion                        *
 *------------------------------------------------------------------*/
 *!
 *  pixExpandBinaryPower2()
 *
 *      Input:  pixs (1 bpp)
 *              factor (expansion factor: 1, 2, 4, 8, 16)
 *      Return: pixd (expanded 1 bpp by replication), or null on error
 *}
function pixExpandBinaryPower2(pixs: PLPix; factor: longint): PLPix; cdecl; external LIBLEPT;

//  === morphseq.c  ===
{*-------------------------------------------------------------------------*
 *         Run a sequence of binary rasterop morphological operations      *
 *-------------------------------------------------------------------------*}

{*!
 *  pixMorphSequence()
 *
 *      Input:  pixs
 *              sequence (string specifying sequence)
 *              dispsep (controls debug display of each result in the sequence:
 *                       0: no output
 *                       > 0: gives horizontal separation in pixels between
 *                            successive displays
 *                       < 0: pdf output; abs(dispsep) is used for naming)
 *      Return: pixd, or null on error
 *
 *  Notes:
 *      (1) This does rasterop morphology on binary images.
 *      (2) This runs a pipeline of operations; no branching is allowed.
 *      (3) This only uses brick Sels, which are created on the fly.
 *          In the future this will be generalized to extract Sels from
 *          a Sela by name.
 *      (4) A new image is always produced; the input image is not changed.
 *      (5) This contains an interpreter, allowing sequences to be
 *          generated and run.
 *      (6) The format of the sequence string is defined below.
 *      (7) In addition to morphological operations, rank order reduction
 *          and replicated expansion allow operations to take place
 *          downscaled by a power of 2.
 *      (8) Intermediate results can optionally be displayed.
 *      (9) Thanks to Dar-Shyang Lee, who had the idea for this and
 *          built the first implementation.
 *      (10) The sequence string is formatted as follows:
 *            - An arbitrary number of operations,  each separated
 *              by a '+' character.  White space is ignored.
 *            - Each operation begins with a case-independent character
 *              specifying the operation:
 *                 d or D  (dilation)
 *                 e or E  (erosion)
 *                 o or O  (opening)
 *                 c or C  (closing)
 *                 r or R  (rank binary reduction)
 *                 x or X  (replicative binary expansion)
 *                 b or B  (add a border of 0 pixels of this size)
 *            - The args to the morphological operations are bricks of hits,
 *              and are formatted as a.b, where a and b are horizontal and
 *              vertical dimensions, rsp.
 *            - The args to the reduction are a sequence of up to 4 integers,
 *              each from 1 to 4.
 *            - The arg to the expansion is a power of two, in the set
 *              {2, 4, 8, 16}.
 *      (11) An example valid sequence is:
 *               "b32 + o1.3 + C3.1 + r23 + e2.2 + D3.2 + X4"
 *           In this example, the following operation sequence is carried out:
 *             * b32: Add a 32 pixel border around the input image
 *             * o1.3: Opening with vert sel of length 3 (e.g., 1 x 3)
 *             * C3.1: Closing with horiz sel of length 3  (e.g., 3 x 1)
 *             * r23: Two successive 2x2 reductions with rank 2 in the first
 *                    and rank 3 in the second.  The result is a 4x reduced pix.
 *             * e2.2: Erosion with a 2x2 sel (origin will be at x,y: 0,0)
 *             * d3.2: Dilation with a 3x2 sel (origin will be at x,y: 1,0)
 *             * X4: 4x replicative expansion, back to original resolution
 *      (12) The safe closing is used.  However, if you implement a
 *           closing as separable dilations followed by separable erosions,
 *           it will not be safe.  For that situation, you need to add
 *           a sufficiently large border as the first operation in
 *           the sequence.  This will be removed automatically at the
 *           end.  There are two cautions:
 *              - When computing what is sufficient, remember that if
 *                reductions are carried out, the border is also reduced.
 *              - The border is removed at the end, so if a border is
 *                added at the beginning, the result must be at the
 *                same resolution as the input!
 *}
function pixMorphSequence(pixs: PLPix; sequence: PChar; dispsep: longint): PLPix;  cdecl; external LIBLEPT;


//  === seedfill.c  ===

{*!
 *  pixSeedfillBinary()
 *
 *      Input:  pixd  (<optional>; this can be null, equal to pixs,
 *                     or different from pixs; 1 bpp)
 *              pixs  (1 bpp seed)
 *              pixm  (1 bpp filling mask)
 *              connectivity  (4 or 8)
 *      Return: pixd always
 *
 *  Notes:
 *      (1) This is for binary seedfill (aka "binary reconstruction").
 *      (2) There are 3 cases:
 *            (a) pixd == null (make a new pixd)
 *            (b) pixd == pixs (in-place)
 *            (c) pixd != pixs
 *      (3) If you know the case, use these patterns for clarity:
 *            (a) pixd = pixSeedfillBinary(NULL, pixs, ...);
 *            (b) pixSeedfillBinary(pixs, pixs, ...);
 *            (c) pixSeedfillBinary(pixd, pixs, ...);
 *      (4) The resulting pixd contains the filled seed.  For some
 *          applications you want to OR it with the inverse of
 *          the filling mask.
 *      (5) The input seed and mask images can be different sizes, but
 *          in typical use the difference, if any, would be only
 *          a few pixels in each direction.  If the sizes differ,
 *          the clipping is handled by the low-level function
 *          seedfillBinaryLow().
 *}
function pixSeedfillBinary(pixd, pixs, pixm: PLPix; connectivity: longint): PLPix; cdecl; external LIBLEPT;


//  === pix3.c  ===

{*!
 *  pixSubtract()
 *
 *      Input:  pixd  (<optional>; this can be null, equal to pixs1,
 *                     equal to pixs2, or different from both pixs1 and pixs2)
 *              pixs1 (can be == pixd)
 *              pixs2 (can be == pixd)
 *      Return: pixd always
 *
 *  Notes:
 *      (1) This gives the set subtraction of two images with equal depth,
 *          aligning them to the the UL corner.  pixs1 and pixs2
 *          need not have the same width and height.
 *      (2) Source pixs2 is always subtracted from source pixs1.
 *          The result is
 *                  pixs1 \ pixs2 = pixs1 & (~pixs2)
 *      (3) There are 4 cases:
 *            (a) pixd == null,   (src1 - src2) --> new pixd
 *            (b) pixd == pixs1,  (src1 - src2) --> src1  (in-place)
 *            (c) pixd == pixs2,  (src1 - src2) --> src2  (in-place)
 *            (d) pixd != pixs1 && pixd != pixs2),
 *                                 (src1 - src2) --> input pixd
 *      (4) For clarity, if the case is known, use these patterns:
 *            (a) pixd = pixSubtract(NULL, pixs1, pixs2);
 *            (b) pixSubtract(pixs1, pixs1, pixs2);
 *            (c) pixSubtract(pixs2, pixs1, pixs2);
 *            (d) pixSubtract(pixd, pixs1, pixs2);
 *      (5) The size of the result is determined by pixs1.
 *      (6) The depths of pixs1 and pixs2 must be equal.
 *}
function pixSubtract(pixd, pixs1, pixs2: PLPix): PLPix; cdecl; external LIBLEPT;

{/*!
 *  makePixelSumTab8()
 *
 *      Input:  void
 *      Return: table of 256 l_int32, or null on error
 *
 *  Notes:
 *      (1) This table of integers gives the number of 1 bits
 *          in the 8 bit index.
 *}
function makePixelSumTab8: plongint;  cdecl; external LIBLEPT;

{*!
 *  pixCountPixels()
 *
 *      Input:  pix (1 bpp)
 *              &count (<return> count of ON pixels)
 *              tab8  (<optional> 8-bit pixel lookup table)
 *      Return: 0 if OK; 1 on error
 *}
function pixCountPixels(pix: PLPix; pcount, tab8: plongint): Longint; cdecl; external LIBLEPT;

//  === rop.c ===

{*--------------------------------------------------------------------*
 *                 Full image rasterop with no shifts                 *
 *--------------------------------------------------------------------*/
/*!
 *  pixRasteropFullImage()
 *
 *      Input:  pixd
 *              pixs
 *              op (any of the op-codes)
 *      Return: 0 if OK; 1 on error
 *
 *  Notes:
 *      - this is a wrapper for a common 2-image raster operation
 *      - both pixs and pixd must be defined
 *      - the operation is performed with aligned UL corners of pixs and pixd
 *      - the operation clips to the smallest pix; if the width or height
 *        of pixd is larger than pixs, some pixels in pixd will be unchanged
 *}
function pixRasteropFullImage(pixd, pixs: PLPix; op: longint): longint; cdecl; external LIBLEPT;




implementation

end.

