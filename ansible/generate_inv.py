#!env python3
import json
import sys
import pathlib


def build_hosts_tmpl(authority_node_ip_address, collator_node_ip_addresses):
    collator_nodes = "\n".join(collator_node_ip_addresses)

    return (f'[authority_node]\n{authority_node_ip_address}\n\n' +
            f'[collator_node]\n{collator_nodes}\n')


def build_inventory_file(inv):
    authority_node_ip_address = inv['authority_node_ip_address']['value']
    bastion_ip_address = inv['bastion_ip_address']['value']
    collator_node_ip_address = inv['collator_node_ip_address']['value']
    collator_node_secondary_ip_address = inv['collator_node_secondary_ip_address']['value']
    collator_node_ip_addresses = collator_node_ip_address + collator_node_secondary_ip_address

    hosts_file = build_hosts_tmpl(authority_node_ip_address,
                                  bastion_ip_address, collator_node_ip_addresses)

    with open('hosts', 'w') as f:
        f.write(hosts_file)


def build_ssh_config(inv):
    with open('{}/ssh_config.template'.format(pathlib.Path(__file__).parent.absolute()), 'r') as f:
        tmpl = f.read()
    res = tmpl.replace('{bastion}', inv['bastion_ip_address']['value'])
    with open('ssh_config', 'w') as f:
        f.write(res)


def main():
    data = sys.stdin.buffer.read()
    inv = json.loads(data)
    build_inventory_file(inv)
    build_ssh_config(inv)


if __name__ == "__main__":
    main()
