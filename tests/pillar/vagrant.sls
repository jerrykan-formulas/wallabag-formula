{%- set ipaddr = salt['grains.get']('ip4_interfaces:eth1:0') -%}

wallabag:
  config:
    database_driver: pdo_pgsql
    database_user: wallabag
    database_name: wallabag
    database_password: wallabagpass
    domain_name: http://{{ ipaddr }}/
