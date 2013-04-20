#!/bin/bash

function run {
  echo $*
  $*
}

function usage_and_exit {
  echo $1
  echo
  echo "USAGE: mvn-sonatype-stage [options]"
  echo "  -a <artifactId>"
  echo "  -v <version>"
  echo "    == OR =="
  echo "  -j <binaryJar>"
  echo "  -p <pomFile>"
  echo "  -s <sourcesJar>"
  echo "  -d <javadocJar>"
  exit
}

while getopts "a:v:j:s:d:p:" opt; do
  case $opt in
    a)
      artifactId=$OPTARG
      ;;
    v)
      version=$OPTARG
      ;;
    j)
      binaryJar=$OPTARG
      ;;
    s)
      sourcesJar=$OPTARG
      ;;
    d)
      javadocJar=$OPTARG
      ;;
    p)
      pomFile=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      ;;
  esac
done

if [[ -n $artifactId && -n $version ]]; then
  pomFile=${artifactId}-${version}.pom
  binaryJar=${artifactId}-${version}.jar
  sourcesJar=${artifactId}-${version}-sources.jar
  javadocJar=${artifactId}-${version}-javadoc.jar
else
  if [[ -z $binaryJar || -z $pomFile || -z ${sourcesJar} || -z ${javadocJar} ]]; then
    usage_and_exit "ERROR: (-a <artifactId> and -v <version>) OR (-j <binaryJar> \
      and -p <pomFile> and -d <javadocJar> and -s <sourcesJar>) must be given"
  fi
fi

goal="gpg:sign-and-deploy-file"
url="https://oss.sonatype.org/service/local/staging/deploy/maven2/"
repositoryId="sonatype-nexus-staging"

host="http://nexus.vip.facebook.com:8181"
base_url="$host/nexus/content"

base_cmd="mvn ${goal} -Durl=${url} -DrepositoryId=${repositoryId} -DpomFile=${pomFile}"

if [[ ! -r ${pomFile} ]]; then
  echo "ERROR: Cannot read pom file at ${pomFile}"
  exit
fi
if [[ ! -r ${binaryJar} ]]; then
  echo "ERROR: Cannot read jar file at ${pomFile}"
  exit
fi
if [[ ! -r ${sourcesJar} ]]; then
  echo "ERROR: Cannot read sources jar file at ${sourcesJar}"
  exit
fi
if [[ ! -r ${javadocJar} ]]; then
  echo "ERROR: Cannot read javadoc jar file at ${javadocJar}"
  exit
fi

run "${base_cmd} -Dfile=${binaryJar}"
run "${base_cmd} -Dfile=${sourcesJar} -Dclassifier=sources"
run "${base_cmd} -Dfile=${javadocJar} -Dclassifier=javadoc"
