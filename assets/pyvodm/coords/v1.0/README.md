# Coordinates model serialization examples

The following directories hold serializations of the various elements of the Coordinates V1.0 data model in the indicated format.
Each file validates according to its format schema.
* vot: VOTable-1.3 standard syntax
    * Validates using votlint
* avot: VOTable-1.3 annotated with VO-DML/Mapping syntax
    * Validates using xmllint to a VOTable-1.3 schema enhanced with an imported VO-DML mapping syntax schema
* xml: XML format
    * Validates against the model schema
* xxx: An internal DOC format
    * XML/DOM structure representing the instances generated when interpreting the templates.


## How were they generated?

These files were generated using a home-grown python utilities which Makes use of Template files describing the data model instance to construct an internal instance which is then exported in the desired format.
* [pyvodm](https://github.com/mcdittmar/pyvodm): package of classes to interpret model maps, build instances and write output
* [voefg](https://github.com/mcdittmar/dm-example-files/tree/master/tools/voefg): In this repo; uses pyvodm to construct the example file suites in this repo.

The Makefile at the top of this repository controls the build and execution commands.

## Alternate Examples

An alternate set of examples, generated with more robust code can be found in the [ivoa-dm-examples](https://github.com/mcdittmar/ivoa-dm-examples/tree/master/assets/examples/coords/current/instances) repository.
That repository contains the files generated using the Jovial software package and contains both the Jovial DSL file and resulting annotated VOTable.

