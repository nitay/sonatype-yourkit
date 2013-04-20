# sonatype-yourkit #

This project is used to make releases
[YourKit Profiler API](http://www.yourkit.com/docs/80/help/api.jsp) to the
[Sonatype Maven Repository](http://goo.gl/FEoeP).

YourKit currently does not publish the API to Maven Central, but their license allows it,
so we are doing it here.

See Sonatype's full [release guide](http://goo.gl/6xeib).
<br/>
The section we are interested in is [Staging Existing Artifacts](http://goo.gl/QsJ99).

We have written some scripts to make things easier. They work for us, but YMMV.

## Step 1: add-version.rb ##
Initializes a version directory with data from a download.

After you download a release of YourKit, for example version 11.0.10, you can run:

Mac: `./add-version.rb  path/to/YourKit_Java_Profiler_11.0.10`
<br/>
Linux / others: `./add-version.rb  path/to/yjp-11.0.10`

This should create a new version directory and copy the right files from your downloaded version.

You should compare this folder against another one in this repository to see that things look right.
<br/>
This script will likely get out of date as YourKit updates how their downloads are structured.
<br/>
If something looks wrong you need to fix it by hand. Also if you can you should update the script.

## Step 2: mvn-sonatype-stage.sh ##
Stages artifacts to Sonatype.

This script is a generic tool we've used to aid in [staging artifacts](http://goo.gl/QsJ99).
<br/>
It is not tied to the structure of YourKit's data or this repository so it should not break.
<br/>
We welcome you to use it in other projects as well.

Keeping with the example previously, if you have added version 11.0.10, you would run:

    cd 11.0.10
    ../mvn-sonatype-stage.sh -a yjp-controller-api-redist -v 11.0.10

## Step 3: Release Staged Artifact ##
This step has to be done by hand.

After staging you need to follow [Sonatype's release process](http://goo.gl/C6Lzo).


