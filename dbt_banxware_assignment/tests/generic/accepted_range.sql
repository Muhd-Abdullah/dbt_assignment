{% test accepted_range(model, column_name, min_value=None, max_value=None, inclusive=True) %}

select *
from {{ model }}
where
(
  {% if min_value is not none %}
    {% if inclusive %}
      {{ column_name }} < {{ min_value }}
    {% else %}
      {{ column_name }} <= {{ min_value }}
    {% endif %}
  {% else %}
    false
  {% endif %}

  {% if max_value is not none %}
    or
    {% if inclusive %}
      {{ column_name }} > {{ max_value }}
    {% else %}
      {{ column_name }} >= {{ max_value }}
    {% endif %}
  {% endif %}
)

{% endtest %}
