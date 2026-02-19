{% macro stable_uuid(fields) -%}
  {# Deterministic UUID-shaped key from business keys (Snowflake MD5) #}
  {% set expr = "coalesce(to_varchar(" ~ fields | join("),'') || '|' || coalesce(to_varchar(") ~ "), '')" %}
  lower(
    substr(md5({{ expr }}), 1, 8) || '-' ||
    substr(md5({{ expr }}), 9, 4) || '-' ||
    substr(md5({{ expr }}), 13, 4) || '-' ||
    substr(md5({{ expr }}), 17, 4) || '-' ||
    substr(md5({{ expr }}), 21, 12)
  )
{%- endmacro %}
