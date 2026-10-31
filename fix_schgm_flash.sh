#!/bin/bash
# Fix schgm-flash compilation and linking errors for OnePlus SM8250 kernel
# The issue:
# 1. schgm-flash.c only includes smb5-lib.h when OPLUS_FEATURE_CHG_BASIC is NOT defined,
#    but for OnePlus devices this macro IS defined, causing missing struct definitions.
# 2. schgm-flash.h declares functions using struct smb_charger* but doesn't include smb5-lib.h
# 3. The Makefile excludes smb5-lib.o when OPLUS_FEATURE_CHG_BASIC is defined,
#    causing linker errors for smblib_write, smblib_read, smblib_masked_write

set -e

echo "Fixing schgm-flash.c compilation error..."

# Fix schgm-flash.c: always include smb5-lib.h
sed -i 's|#ifndef OPLUS_FEATURE_CHG_BASIC|#if 0 // OPLUS_FEATURE_CHG_BASIC - always include smb5-lib.h|' drivers/power/supply/qcom/schgm-flash.c

# Fix schgm-flash.h: include smb5-lib.h for struct smb_charger definition
# Add after the first include line
sed -i '/^#include <linux\/bitops.h>/a #include "smb5-lib.h"' drivers/power/supply/qcom/schgm-flash.h

echo "Fixing Makefile to include smb5-lib.o..."

# Fix Makefile: include smb5-lib.o even when OPLUS_FEATURE_CHG_BASIC is defined
# The Makefile uses C preprocessor directives (#ifdef) which are processed by the build system
# We need to modify the branch that's taken when OPLUS_FEATURE_CHG_BASIC is defined
sed -i 's|obj-$(CONFIG_QPNP_SMB5)			+= step-chg-jeita.o battery.o pmic-voter.o storm-watch.o schgm-flash.o|obj-$(CONFIG_QPNP_SMB5)			+= step-chg-jeita.o battery.o qpnp-smb5.o smb5-lib.o pmic-voter.o storm-watch.o schgm-flash.o|' drivers/power/supply/qcom/Makefile

echo "schgm-flash fix applied successfully"