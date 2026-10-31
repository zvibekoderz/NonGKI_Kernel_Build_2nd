#!/bin/bash
# Fix schgm-flash compilation error for OnePlus SM8250 kernel
# The issue: schgm-flash.c only includes smb5-lib.h when OPLUS_FEATURE_CHG_BASIC is NOT defined,
# but for OnePlus devices this macro IS defined, causing missing struct definitions.
# Also, schgm-flash.h declares functions using struct smb_charger* but doesn't include smb5-lib.h

set -e

echo "Fixing schgm-flash.c compilation error..."

# Fix schgm-flash.c: always include smb5-lib.h
sed -i 's|#ifndef OPLUS_FEATURE_CHG_BASIC|#if 0 // OPLUS_FEATURE_CHG_BASIC - always include smb5-lib.h|' drivers/power/supply/qcom/schgm-flash.c

# Fix schgm-flash.h: include smb5-lib.h for struct smb_charger definition
# Add after the first include line
sed -i '/^#include <linux\/bitops.h>/a #include "smb5-lib.h"' drivers/power/supply/qcom/schgm-flash.h

echo "schgm-flash fix applied successfully"