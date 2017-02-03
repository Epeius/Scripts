import idc
import idaapi
import idautils
import time

def getBlock(tgtEA):
    '''
    Get the basic block for taget EA, returns None if not found
    '''
    f = idaapi.get_func(tgtEA)
    if not f:
        return None


    fc = idaapi.FlowChart(f)
    p = idaapi.node_info_t()
    p.bg_color = 0x00ff00 # green
    for block in fc:
        if block.startEA <= tgtEA:
            if block.endEA > tgtEA:
                for ea in Heads(block.startEA, block.endEA):
                    SetColor(ea, CIC_ITEM, 0x00ff00)
                return block

    return None

if __name__ == "__main__":
    FtouchedBBs = open("TouchedBB.txt", 'r')
    for line in FtouchedBBs.read().split('\n'):
        BB = getBlock(int(line, 16))
        if BB is None:
            print "cannot find BB for %s" % line
        else:
            print "successfully marked BB for %s" % line
