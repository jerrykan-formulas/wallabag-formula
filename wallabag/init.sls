{%- from "wallabag/map.jinja" import wallabag with context -%}

{%- set config = salt['pillar.get']('wallabag:config', {}) -%}

wallabag-dependencies:
  pkg.installed:
    - pkgs:
{%- if config['database_driver'] == 'pdo_pgsql' %}
      - {{ wallabag.pkg_postgresql }}
{%- elif config['database_driver'] == 'pdo_mysql' %}
      - {{ wallabag.pkg_mysql }}
{%- elif config['database_driver'] == 'pdo_sqlite' %}
      - {{ wallabag.pkg_sqlite }}
{%- endif %}
{%- for package in wallabag.php_modules %}
      - {{ package }}
{%- endfor %}

wallabag-dir:
  file.directory:
    - name: {{ wallabag.install_dir }}
    - user: {{ wallabag.user }}
    - group: {{ wallabag.user }}

wallabag-files:
  archive.extracted:
    - name: {{ wallabag.install_dir }}
    - source: {{ wallabag.archive }}
{%- if wallabag.archive_hash %}
    - source_hash: {{ wallabag.archive_hash }}
{%- else %}
    - skip_verify: True
{%- endif %}
    - archive_format: tar
    - options: '--strip-components=1'
    - user: {{ wallabag.user }}
    - group: {{ wallabag.user }}
    - enforce_toplevel: False
    - require:
      - file: wallabag-dir

wallabag-config:
  file.managed:
    - name: {{ wallabag.install_dir }}/app/config/parameters.yml
    - source: salt://wallabag/files/parameters.yml.jinja
    - template: jinja
    - user: {{ wallabag.user }}
    - group: {{ wallabag.user }}
    - mode: 640
    - require:
      - file: wallabag-dir

wallabag-clear-cache:
  cmd.run:
    - name: rm -rf {{ wallabag.install_dir }}/var/cache
    - cwd: {{ wallabag.install_dir }}
    - user: {{ wallabag.user }}
    - onchanges:
      - file: wallabag-config

wallabag-config-update:
  cmd.run:
    - name: /usr/bin/php {{ wallabag.install_dir }}/bin/console wallabag:install --no-interaction --env=prod
    - cwd: {{ wallabag.install_dir }}
    - user: {{ wallabag.user }}
    - onchanges:
      - cmd: wallabag-clear-cache
