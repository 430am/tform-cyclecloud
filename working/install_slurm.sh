
#!/bin/bash

echo "Setting up the slurm cluster!"
SLURMTEMPLATE=\$(runuser -l $ADMINUSER -c 'cyclecloud show_cluster  -t' | grep  'slurm.*template' | awk '{print \$1}' )
echo "SLURMTEMPLATE=\$SLURMTEMPLATE"
runuser -l $ADMINUSER -c 'cyclecloud show_cluster  -t' | grep  'slurm.*template'  | awk '{print \$1}'
SLURMTEMPLATE=\$(runuser -l $ADMINUSER -c 'cyclecloud show_cluster  -t' | grep  "slurm.*template" | cut -d':' -f1)
runuser -l $ADMINUSER -c "cyclecloud create_cluster \$SLURMTEMPLATE $CLUSTERNAME -p /tmp/$CLUSTERPARAMETERFILE"
runuser -l $ADMINUSER -c "cyclecloud start_cluster $CLUSTERNAME"

echo "Waiting for scheduler to be up-and-running..."
max_provisioning_time=120
max_retries=20
wait_time=20
get_state(){ runuser -l $ADMINUSER -c "cyclecloud show_nodes scheduler -c $CLUSTERNAME --states='Started' --output='%(Status)s'" ; }

for (( r=1; r<=max_retries; r++ )); do

   schedulerstate=\$(get_state)
   echo \$schedulerstate
   if [ "\$schedulerstate" == "Failed" ]; then
           runuser -l $ADMINUSER -c "cyclecloud retry $CLUSTERNAME"
           sleep \$wait_time
   elif [ "\$schedulerstate" == "Ready" ]; then
           echo "Scheduler provisioned"
           break
   elif [ "\$schedulerstate" == "Off" ]; then
           echo "Scheduler provisioning has not started yet"
           sleep \$wait_time
   elif [ "\$schedulerstate" == "Acquiring" ] || [ "\$schedulerstate" == "Preparing" ] ; then
       start_time=\$(date +%s)
       while true; do
           echo -n "."
           sleep \$wait_time
           current_time=\$(date +%s)
           elapsed_time=\$((current_time - start_time))

           if [ \$elapsed_time -ge \$max_provisioning_time ]; then
                   break
           fi
           schedulerstate=\$(get_state)
           if [ "\$schedulerstate" != "Acquiring" ] && [ "\$schedulerstate" != "Preparing" ]  ; then
                   break
           fi
       done
   fi

done
echo "Final scheduler state = \$schedulerstate"