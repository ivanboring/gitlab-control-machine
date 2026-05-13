#!/usr/bin/env bash

set -eu -o pipefail
cd $APP_ROOT

# Create required composer.json and composer.lock files.
composer create-project --no-install ${PROJECT:=drupal/recommended-project}:^11
cp -r ${PROJECT#*/}/* ./
rm -rf ${PROJECT#*/}

# Scaffold settings.php.
composer config -jm extra.drupal-scaffold.file-mapping '{
    "[web-root]/sites/default/settings.php": {
        "path": "web/core/assets/scaffold/files/default.settings.php",
        "overwrite": false
    }
}'
composer config scripts.post-drupal-scaffold-cmd \
    'cd web/sites/default && test -z "$(grep '\''include \$devpanel_settings;'\'' settings.php)" && patch -Np1 -r /dev/null < $APP_ROOT/.devpanel/drupal-settings.patch || :'

# Add Drush.
composer require -n --no-update drush/drush

# Make sure that dev stability packages are allowed.
composer config -n minimum-stability dev

# Add extra packages for development.
composer require -n --no-update \
    drupal/eca_tool:1.0.x-dev@dev \
    drupal/admin_toolbar:^3.6 \
    drupal/gitlab_api:^3.0@alpha \
    drupal/modeler:^1.0
