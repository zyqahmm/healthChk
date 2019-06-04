#!/bin/bash

export DATE=`date +%Y-%m-%d-%H-%M-%S`
sed -i '/^DATE.*/d' /tmp/inventory
echo "DATE=$DATE" >> /tmp/inventory
ansible-playbook  inforcollect.yml -i /tmp/inventory 
