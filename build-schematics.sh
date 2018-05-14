#!/usr/bin/env bash

set -u -e -o pipefail

readonly currentDir=$(cd $(dirname $0); pwd)
cd ${currentDir}

BUILD=false
TEST=false
for ARG in "$@"; do
  case "$ARG" in
    -t)
      TEST=true
      ;;
    -b)
      BUILD=true
      ;;
  esac
done

VERSION=$(node -p "require('./package.json').version")
ZORROVERSION=$(node -p "require('./package.json').dependencies['ng-zorro-antd']")
echo "=====BUILDING: Version ${VERSION}, Zorro Version ${ZORROVERSION}"

N="
"
PWD=`pwd`
TSC=${PWD}/node_modules/.bin/tsc
JASMINE=${PWD}/node_modules/.bin/jasmine

SOURCE=${PWD}/packages/schematics/
DIST=${PWD}/publish/schematics/

updateVersionReferences() {
  NPM_DIR="$1"
  (
    echo "======    VERSION: Updating version references in ${NPM_DIR}"
    cd ${NPM_DIR}
    perl -p -i -e "s/ZORRO\-0\.0\.0\-PLACEHOLDER/${ZORROVERSION}/g" $(grep -ril ZORRO\-0\.0\.0\-PLACEHOLDER .) < /dev/null 2> /dev/null
    perl -p -i -e "s/PEER\-0\.0\.0\-PLACEHOLDER/^${VERSION}/g" $(grep -ril PEER\-0\.0\.0\-PLACEHOLDER .) < /dev/null 2> /dev/null
    perl -p -i -e "s/0\.0\.0\-PLACEHOLDER/${VERSION}/g" $(grep -ril 0\.0\.0\-PLACEHOLDER .) < /dev/null 2> /dev/null
  )
}

tsconfigFile=${SOURCE}/tsconfig.json
if [[ ${TEST} == true ]]; then
  tsconfigFile=${SOURCE}/tsconfig.spec.json
  DIST=${PWD}/dist/schematics-test/
fi

if [[ ${BUILD} == true ]]; then
  rm -rf ${DIST}

  echo "Building...${tsconfigFile}"
  $TSC -p ${tsconfigFile}
  rsync -am --include="*.json" --include="*/" --exclude=* ${SOURCE}/ ${DIST}/
  rsync -am --include="*.d.ts" --include="*/" --exclude=* ${SOURCE}/ ${DIST}/
  rm ${DIST}/tsconfig.json ${DIST}/tsconfig.spec.json

  updateVersionReferences ${DIST}
fi

if [[ ${TEST} == true ]]; then
  echo "jasmine"
  $JASMINE ${DIST}/**/*_spec.js
fi

echo "Finished test-schematics"

# clear | npm run test:schematics
