#!/bin/bash

#if [ ! -d "$DIRECTORY" ]; then
#  # Control will enter here if $DIRECTORY exists.
#  mkdir ./oca
#fi
## shellcheck disable=SC2164
#cd ./oca
#rr=("server-brand" "l10n-ecuador" "l10n-luxemburg" "stock-logistics-barcode" "stock-logistics-tracking" "connector" "l10n-germany" "l10n-estonia" "l10n-chile" "connector-woocommerce" "sale-workflow" "vertical-association" "l10n-taiwan" "webkit-tools" "edi" "l10n-belarus" "account-financial-tools" "calendar" "maintenance" "l10n-finland" "account-fiscal-rule" "vertical-ngo" "l10n-india" "dotnet" "l10n-peru" "multi-company" "e-commerce" "vertical-travel" "social" "pos" "website-themes" "credit-control" "stock-logistics-warehouse" "l10n-ireland" "purchase-workflow" "connector-ecommerce" "l10n-austria" "delivery-carrier" "vertical-abbey" "ddmrp" "server-ux" "margin-analysis" "connector-spscommerce" "connector-salesforce" "l10n-united-kingdom" "project" "operating-unit" "sale-financial" "l10n-france" "rma" "server-tools" "l10n-spain" "event" "l10n-mexico" "mis-builder-contrib" "l10n-portugal" "connector-lengow" "l10n-morocco" "product-attribute" "project-agile" "l10n-vietnam" "webhook" "l10n-ethiopia" "manufacture" "vertical-agriculture" "apps-store" "data-protection" "account-closing" "l10n-poland" "account-reconcile" "knowledge" "l10n-costa-rica" "connector-infor" "management-system" "l10n-thailand" "geospatial" "website-cms" "hr" "community-data-files" "business-requirement" "server-auth" "field-service" "manufacture-reporting" "l10n-japan" "l10n-usa" "stock-logistics-transport" "queue" "survey" "web" "vertical-construction" "l10n-canada" "sale-reporting" "connector-jira" "account-invoicing" "server-backend" "connector-cmis" "product-kitting" "account-consolidation" "l10n-switzerland" "connector-odoo2odoo" "l10n-argentina" "runbot-addons" "l10n-colombia" "website" "vertical-isp" "connector-lims" "rest-framework" "timesheet" "donation" "account-financial-reporting" "purchase-reporting" "l10n-turkey" "l10n-greece" "commission" "mis-builder" "currency" "l10n-iran" "vertical-hotel" "connector-prestashop" "l10n-venezuela" "crm" "account-payment" "infrastructure" "connector-sage" "l10n-norway" "helpdesk" "vertical-edition" "report-print-send" "account-invoice-reporting" "connector-redmine" "vertical-community" "bank-payment" "project-reporting" "iot" "contract" "connector-interfaces" "l10n-belgium" "partner-contact" "reporting-engine" "intrastat-extrastat" "l10n-romania" "account-analytic" "connector-accountedge" "stock-logistics-workflow" "account-budgeting" "server-env" "connector-magento" "bank-statement-import" "l10n-brazil" "vertical-education" "product-variant" "stock-logistics-reporting" "interface-github" "l10n-netherlands" "connector-telephony" "l10n-italy")
#
#for i in "${rr[@]}"; do git clone -b 11.0 https://github.com/oca/${i}; done
## shellcheck disable=SC2103
#cd ..

if [ ! -d "$DIRECTORY" ]; then
  # Control will enter here if $DIRECTORY exists.
  mkdir ./muk-it
fi
# shellcheck disable=SC2164
cd ./muk-it
rr=("muk_dms" "muk_web" "muk_website" "muk_misc" "muk_quality" "muk_base")
for i in "${rr[@]}"; do git clone -b 11.0 --single-branch https://github.com/muk-it/${i}; done
cd ..

if [ ! -d "$DIRECTORY" ]; then
  # Control will enter here if $DIRECTORY exists.
  mkdir ./luc-demeyer
fi
# shellcheck disable=SC2164
cd ./luc-demeyer
rr=("noviat-apps")
for i in "${rr[@]}"; do git clone -b 11.0 --single-branch https://github.com/luc-demeyer/${i}; done
cd ..

if [ ! -d "$DIRECTORY" ]; then
  # Control will enter here if $DIRECTORY exists.
  mkdir ./Openworx
fi
# shellcheck disable=SC2164
cd ./Openworx
rr=("backend_theme")
for i in "${rr[@]}"; do git clone -b 11.0 --single-branch https://github.com/Openworx/${i}; done
cd ..

if [ ! -d "$DIRECTORY" ]; then
  # Control will enter here if $DIRECTORY exists.
  mkdir ./rosenvladimirov
fi
# shellcheck disable=SC2164
cd ./rosenvladimirov
rr=("manufacture-reporting" "l10n-bulgaria" "intrastat-extrastat" "purchase-reporting" "stock-logistics-warehouse" "account-invoice-reporting" "stock-logistics-barcode" "sale-reporting" "account-analytic" "medical" "website" "stock-logistics-workflow" "maintenance" "stock-logistics-reporting" "manufacture" "survey" "geospatial" "account-payment" "server-ux" "product-attribute" "account-financial-reporting" "reporting-engine" "reporting-engine-new" "l10n_bg-locales" "partner-contact" "account-invoicing" "hr" "bank-payment" "purchase-workflow" "report-print-send" "stock-logistics-tracking" "fleet" "web" "sale-workflow" "product-variant" "bank-statement-import" "knowledge" "account-financial-tools" "currency")
for i in "${rr[@]}"; do git clone -b 11.0 --single-branch git@github.com:rosenvladimirov/${i}; done
cd ..
