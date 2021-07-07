  
import os
from pyats.easypy import run
from genie import testbed
import yaml


def main(runtime):
    runtime.mailbot.mailto = ['agorbachev']
    tb = testbed.load(os.path.join('./testbed.yaml'))
    
    
    #for seq in range(22):
    for seq in [22]:
        prefix = "comp-{:02d}".format(seq + 1)
        
        tb.devices['localhost'].custom.rg = 'rg-' + prefix
        tb.devices['localhost'].custom.prefix = prefix
        tb.devices['tshoot-cisco-eastus'].connections.ssh.ip = 'eastus.' + prefix + '.az.skillscloud.company'
        tb.devices['tshoot-cisco-westus'].connections.ssh.ip = 'westus.' + prefix + '.az.skillscloud.company'
        tb.devices['tshoot-cisco-southcentralus'].connections.ssh.ip = 'southcentralus.' + prefix + '.az.skillscloud.company'
        
        run(testscript = './ut.py', testbed=tb, datafile=yaml.safe_load('./marking.yaml'), taskid = "Competitor {:02d}".format(seq + 1))
    
