
function failed() {
    echo "Failed: $@" >&2
    exit 1
}

# 当前目录
CURRENT_DIR=${PWD}

# 获取脚本所在目录
SCRIPT_DIR_RELATIVE=`dirname $0`
SCRIPT_DIR=`cd ${SCRIPT_DIR_RELATIVE}; pwd`
echo "SCRIPT_DIR = ${SCRIPT_DIR}"

# 读取配置
. ${SCRIPT_DIR}/iosPublish.config

mkdir -pv ${APP_DIR} || failed "mkdir ${APP_DIR}"

cd ${PROJECT_DIR} || failed "cd ${PROJECT_DIR}"

# clean
xcodebuild -workspace ${WORKSPACE_NAME}.xcworkspace -scheme ${SCHEME_NAME} -sdk ${SDK_VERSION} -configuration ${CONFIGURATION} ONLY_ACTIVE_ARCH=NO clean || failed "xcodebuild clean"

# archive
xcodebuild -workspace ${WORKSPACE_NAME}.xcworkspace -scheme ${SCHEME_NAME} -sdk ${SDK_VERSION} -configuration ${CONFIGURATION} -destination ${ARCHIVE_DESTINATION} -archivePath ${APP_DIR}/${APP_NAME}.xcarchive ONLY_ACTIVE_ARCH=NO archive || failed "xcodebuild archive"

# export ipa
TIMESTAMP=`date "+%Y_%m_%d_%H_%M_%S"`
IPA_PATH_NO_SUFFIX=${APP_DIR}/${APP_NAME}_${TIMESTAMP}
xcodebuild -exportArchive -archivePath ${APP_DIR}/${APP_NAME}.xcarchive -exportPath ${IPA_PATH_NO_SUFFIX} -exportProvisioningProfile "${PROFILE_NAME}" -exportFormat ipa -verbose || failed "xcodebuild export archive"

# upload to fir.im
fir publish ${IPA_PATH_NO_SUFFIX}.ipa -T ${FIR_TOKEN} || failed "fir publish"

cd ${CURRENT_DIR}
echo "done..."
