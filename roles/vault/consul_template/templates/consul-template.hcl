vault {
    address = "{{ vault_url }}"
    renew_token=true
}
{% set template_opts = 'create_dest_dirs = true
    error_fatal = true
    perms = "0600"
    user = "0"
    group = "0"
    left_delimiter  = "<<"
    right_delimiter = ">>"'%}

{# Iterate over each Certificate authority in issued_certificate_authorities #}
{% for issued_certificate_authority in (issued_certificate_authorities|default([])) %}
{% set ca = vault_pki_engines[issued_certificate_authority] %}
template = {
    {{ template_opts }}
    destination = "{{ ca.save_path }}"
    contents = "<< with secret \"{{ ca.path }}/cert/ca\" >><< .Data.certificate >><< end >>"
}
{% endfor %}

{# Iterate over each certificate in issued_certificates #}
{% for issued_certificate in (issued_certificates|default([])) %}
{%- if issued_certificate in vault_certificates -%}
{%- set cert = vault_certificates[issued_certificate] -%}
{%- set ca = vault_pki_engines[cert.ca] -%}
{%- set secret = ('with secret \\\"%s/issue/%s\\\"' | format(ca.path,cert.role_name)) -%}
{%- set options = ["\\\"exclude_cn_from_sans=true\\\"", "\\\"common_name=" + (cert.cert | default({})).pop('common_name', cert.role_name) + "\\\"" ] -%}
{%- if 'cert' in cert -%}
{%- for cert_option_key, cert_option_value in cert.cert.items() -%}{{ options.append("\\\"%s=%s\\\"" | format(cert_option_key, (cert_option_value | join(',')))) }}{% endfor %}
{%- endif -%}
template = {
    {{ template_opts }}
    destination = "{{ cert.save_path }}.crt"
    contents = "<< {{ secret }} {{ options | join(' ')}} >><< .Data.certificate >><< end >>"
}
template = {
    {{ template_opts }}
    destination = "{{ cert.save_path }}.key"
    contents = "<< {{ secret }} {{ options | join(' ')}} >><< .Data.private_key >><< end >>"
}
{% endif %}
{% endfor %}
{# Iterate over each pubkey pair in pubkey_pairs#}
{% for issued_pubkey_pair in (issued_pubkey_pairs|default([]))%}
{%- if issued_pubkey_pair in vault_pubkey_pairs -%}
{%- set keypair = vault_pubkey_pairs[issued_pubkey_pair] -%}
{%- set keypair_engine = vault_kv_engines[keypair.engine] -%}
template = {
    {{ template_opts }}
    destination = "{{ keypair.save_path }}.pub"
    contents = "<< with secret \"{{ keypair_engine.path }}/{{ keypair.pubkey_path }}\" >><< .Data.data.key >><< end >>"
}
template = {
    {{ template_opts }}
    destination = "{{ keypair.save_path }}.key"
    contents = "<< with secret \"{{ keypair_engine.path }}/{{ keypair.privkey_path }}\" >><< .Data.data.key >><< end >>"
}
{% endif %}
{% endfor %}
