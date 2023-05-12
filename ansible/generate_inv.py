#!env python3
import json
import sys
import pathlib


def build_hosts_tmpl(validator_node_ip_address):
    ip = "".join(validator_node_ip_address)
    return (f'[validator_node]\n{ip}\n')

def build_inventory_file(inv):
    validator_node_ip_address = inv['validator_node_ip_address']['value']

    hosts_file = build_hosts_tmpl(validator_node_ip_address)

    with open('hosts', 'w') as f:
        f.write(hosts_file)


def build_ssh_config(inv):
    with open('{}/ssh_config.template'.format(pathlib.Path(__file__).parent.absolute()), 'r') as f:
        tmpl = f.read()
    validator_node_ip_address = inv['validator_node_ip_address']['value']
    ip = "".join(validator_node_ip_address)
    print(ip);
    res = tmpl.replace('{validator}',ip)
    with open('ssh_config', 'w') as f:
        f.write(res)


def main():
    data = sys.stdin.buffer.read()
    inv = json.loads(data)
    build_inventory_file(inv)
    build_ssh_config(inv)


if __name__ == "__main__":
    main()
