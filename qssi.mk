# Enable AVB 2.0
BOARD_AVB_ENABLE := true

PRODUCT_SOONG_NAMESPACES += \
    hardware/google/av \
    hardware/google/interfaces

# define flag to determine the kernel
TARGET_KERNEL_VERSION := $(shell ls kernel | grep "msm-*" | sed 's/msm-//')

# Set flags for 4.14 and higher kernels
ifeq ($(TARGET_KERNEL_VERSION),$(filter $(TARGET_KERNEL_VERSION),3.18 4.4 4.9))
TARGET_USES_NEW_ION := false
else
TARGET_USES_NEW_ION := true
#Enable llvm support for kernel
KERNEL_LLVM_SUPPORT := true
#Enable sd-llvm suppport for kernel
KERNEL_SD_LLVM_SUPPORT := true
endif

KERNEL_DEFCONFIG := sdm845_defconfig
ifeq ($(wildcard kernel/msm-$(TARGET_KERNEL_VERSION)/arch/arm64/configs/$(KERNEL_DEFCONFIG)),)
KERNEL_DEFCONFIG := $(shell ls ./kernel/msm-$(TARGET_KERNEL_VERSION)/arch/arm64/configs/vendor | grep sm8..._defconfig)
endif

BUILD_BROKEN_PHONY_TARGETS := true
BUILD_BROKEN_DUP_RULES := true
TEMPORARY_DISABLE_PATH_RESTRICTIONS := true
export TEMPORARY_DISABLE_PATH_RESTRICTIONS

VENDOR_QTI_PLATFORM := msmnile
VENDOR_QTI_DEVICE := qssi

#QSSI configuration
#Single system image project structure
TARGET_USES_QSSI := true

ENABLE_AB ?= true

# Enable chain partition for system, to facilitate system-only OTA in Treble.
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

TARGET_DEFINES_DALVIK_HEAP := true
$(call inherit-product, device/qcom/qssi/common64.mk)

#Inherit all except heap growth limit from phone-xhdpi-2048-dalvik-heap.mk
PRODUCT_PROPERTY_OVERRIDES  += \
	dalvik.vm.heapstartsize=8m \
	dalvik.vm.heapsize=512m \
	dalvik.vm.heaptargetutilization=0.75 \
	dalvik.vm.heapminfree=512k \
	dalvik.vm.heapmaxfree=8m


PRODUCT_NAME := $(VENDOR_QTI_DEVICE)
PRODUCT_DEVICE := $(VENDOR_QTI_DEVICE)
PRODUCT_BRAND := qti
PRODUCT_MODEL := qssi system image for arm64

#Initial bringup flags
TARGET_USES_AOSP := false
TARGET_USES_AOSP_FOR_AUDIO := false
TARGET_USES_QCOM_BSP := false

# RRO configuration
TARGET_USES_RRO := true

TARGET_USES_NQ_NFC := true

# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard

BOARD_FRP_PARTITION_NAME := frp

#Android EGL implementation
PRODUCT_PACKAGES += libGLES_android

-include hardware/qcom/display/config/msmnile.mk


PRODUCT_BOOT_JARS += tcmiface
PRODUCT_BOOT_JARS += telephony-ext
PRODUCT_PACKAGES += telephony-ext


TARGET_ENABLE_QC_AV_ENHANCEMENTS := false

TARGET_DISABLE_DASH := true
TARGET_DISABLE_QTI_VPP := false

ifneq ($(TARGET_DISABLE_DASH), true)
    PRODUCT_BOOT_JARS += qcmediaplayer
endif

#Project is missing on sdm845, comment it for now
#ifneq ($(strip $(QCPATH)),)
#    PRODUCT_BOOT_JARS += libprotobuf-java_mls
#endif

# Video codec configuration files
ifeq ($(TARGET_ENABLE_QC_AV_ENHANCEMENTS), true)
PRODUCT_PROPERTY_OVERRIDES += \
    media.settings.xml=/vendor/etc/media_profiles_vendor.xml
endif #TARGET_ENABLE_QC_AV_ENHANCEMENTS

PRODUCT_PACKAGES += android.hardware.media.omx@1.0-impl

# Audio configuration file
-include $(TOPDIR)hardware/qcom/audio/configs/msmnile/msmnile.mk
-include $(TOPDIR)vendor/qcom/opensource/audio-hal/primary-hal/configs/qssi/qssi.mk

USE_CUSTOM_AUDIO_POLICY := 0

PRODUCT_PACKAGES += fs_config_files

ifeq ($(ENABLE_AB), true)
#A/B related packages
PRODUCT_PACKAGES += update_engine \
    update_engine_client \
    update_verifier \
    bootctrl.msmnile \
    brillo_update_payload \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service

#Boot control HAL test app
PRODUCT_PACKAGES_DEBUG += bootctl
endif

#Healthd packages
PRODUCT_PACKAGES += \
    android.hardware.health@1.0-impl \
    android.hardware.health@1.0-convert \
    android.hardware.health@1.0-service \
    libhealthd.msm

DEVICE_MATRIX_FILE   := device/qcom/common/compatibility_matrix.xml
DEVICE_FRAMEWORK_MANIFEST_FILE := device/qcom/qssi/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml


#ANT+ stack
PRODUCT_PACKAGES += \
    AntHalService \
    libantradio \
    antradio_app \
    libvolumelistener

# Display/Graphics
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.0-service \
    android.hardware.broadcastradio@1.0-impl

# Camera configuration file. Shared by passthrough/binderized camera HAL
PRODUCT_PACKAGES += camera.device@3.2-impl
PRODUCT_PACKAGES += camera.device@1.0-impl
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl
# Enable binderized camera HAL
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service_64

# Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator@1.2-service

# Context hub HAL
PRODUCT_PACKAGES += \
    android.hardware.contexthub@1.0-impl.generic \
    android.hardware.contexthub@1.0-service

# system prop for Bluetooth SOC type
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.qcom.bluetooth.soc=cherokee

# system prop for enabling QFS (QTI Fingerprint Solution)
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.qfp=true


# USB default HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

#PASR HAL and APP
PRODUCT_PACKAGES += \
    vendor.qti.power.pasrmanager@1.0-service \
    vendor.qti.power.pasrmanager@1.0-impl \
    pasrservice

# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/$(PRODUCT_NAME)/$(KERNEL_MODULES_INSTALL)/lib/modules


#Exclude vibrator from InputManager
PRODUCT_COPY_FILES += \
    device/qcom/qssi/excluded-input-devices.xml:system/etc/excluded-input-devices.xml

#Enable full treble flag
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

KMGK_USE_QTI_SERVICE := true

#Enable KEYMASTER 4.0
ENABLE_KM_4_0 := true
#Should be enabled only on msmnile
ENABLE_STRONGBOX_KM := true

ifneq ($(strip $(TARGET_USES_RRO)),true)
DEVICE_PACKAGE_OVERLAYS += device/qcom/qssi/overlay
endif


ENABLE_VENDOR_RIL_SERVICE := true
#Enable vndk-sp Libraries
PRODUCT_PACKAGES += vndk_package

PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE:=true

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
include device/qcom/wlan/msmnile/wlan.mk

TARGET_MOUNT_POINTS_SYMLINKS := false

# propery "ro.vendor.build.security_patch" is checked for
# # CTS compliance so need to make sure its set with following
# # format "YYYY-MM-DD" on production devices.
# #
ifeq ($(ENABLE_VENDOR_IMAGE), true)
 VENDOR_SECURITY_PATCH := 2018-06-05
endif

TARGET_USES_MKE2FS := true

PRODUCT_PROPERTY_OVERRIDES += \
ro.crypto.volume.filenames_mode = "aes-256-cts" \
ro.crypto.allow_encrypt_override = true

TARGET_USES_QCOM_DISPLAY_BSP := true

ifeq ($(TARGET_USES_NEW_ION),true)
AUDIO_FEATURE_ENABLED_DLKM := true
else
AUDIO_FEATURE_ENABLED_DLKM := false
endif

$(call inherit-product, build/make/target/product/product_launched_with_p.mk)


###################################################################################
# This is the End of target.mk file.
# Now, Pickup other split product.mk files:
###################################################################################
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/*.mk)
###################################################################################
