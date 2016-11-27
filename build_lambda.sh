#!/usr/bin/env bash
VIRTUAL_ENV="awslambdaconverter"
AWS_LAMBDA_DIR="lambda"
BUILD_FILE="image_resize.zip"

virtualenv ${VIRTUAL_ENV}
source activate ${VIRTUAL_ENV}
pip install -r ${AWS_LAMBDA_DIR}/Requirements

WORKSPACE="build"
rm -rf ${BUILD_FILE}
mkdir ${WORKSPACE}
cp -r ${VIRTUAL_ENV}/lib/python2.7/site-packages/* ${WORKSPACE}/
cp ${AWS_LAMBDA_DIR}/*.py ${WORKSPACE}/
cd ${WORKSPACE} ; zip -r ../${BUILD_FILE} . * ; cd ..

rm -rf ${WORKSPACE}
source deactivate ${VIRTUAL_ENV}
rm -rf ${VIRTUAL_ENV}