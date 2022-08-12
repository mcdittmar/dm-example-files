# Measurements model serialization examples

The following directories hold serializations of the various elements of the Measurements V1.0 data model in the indicated format.
Each file validates according to its format schema.
* vot: VOTable-1.3 standard syntax
    * Validates using votlint
* avot: VOTable-1.3 annotated with VO-DML/Mapping syntax
    * Validates using xmllint to a VOTable-1.3 schema enhanced with an imported VO-DML mapping syntax schema
* xml: XML format
    * Validates against the model schema
* xxx: An internal DOC format
    * XML/DOM structure representing the instances generated when interpreting the templates.

## Example summary:
The Measurements model uses the Coordinates model to express the measured value and associated coordinate space/frame.  
As such, these examples serve to show how one expresses various Physical Quantities.
These representations remain valid regardless of the context in which they reside (Catalogue, Cube, TimeSeries, Spectrum, Photometry, etc )

* Magnitude: expressed as a GenericMeasure with symmetric errors 
* Polarization:
* Position:
    * 2D Position in Galactic frame
    * 2D Position in Equatorial frame with elliptical errors
    * 2D Position in Ecliptic frame with symmetrical errors
    * 3D Position in Cartesian coordinate space with ellipsoidal error
    * Custom positions using GenericPoint and user defined coordinate spaces with asymmetric errors
        * 1D - radial distance in custom coordinate space 
        * 2D - custom coordinate space (Theta, Phi)
        * 3D - Spherical coordinate space (R,Theta,Phi)
* Proper Motion:
* Time: Mission elapsed time in seconds from reference MJD day with symmetric error
* Velocity: Custom velocities
    * 1D with generic coordinate space and bounds error
    * 2D with generic coordinate space and bounds error
    * 3D with cartesian coordinate space and bounds error

## How were they generated?

These files were generated using a home-grown python utilities which Makes use of Template files describing the data model instance to construct an internal instance which is then exported in the desired format.
* [pyvodm](https://github.com/mcdittmar/pyvodm): package of classes to interpret model maps, build instances and write output
* [voefg](https://github.com/mcdittmar/dm-example-files/tree/master/tools/voefg): In this repo; uses pyvodm to construct the example file suites in this repo.

The Makefile at the top of this repository controls the build and execution commands.

## Alternate Examples

An alternate set of examples, generated with more robust code can be found in the [ivoa-dm-examples](https://github.com/mcdittmar/ivoa-dm-examples/tree/master/assets/examples/meas/current/instances) repository.
That repository contains the files generated using the Jovial software package and contains both the Jovial DSL file and resulting annotated VOTable.
