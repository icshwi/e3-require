#
# It is impossible to maintain this kind of makefile with no knowledge
# on the entire history of the makefile development and on PSI envrionment.
# So, I decide to split them into several pieces which I can look at how
# they work and I would like to remove duplicate and unncessary lines for
# ESS.
#
# In addition, I would like to remove GLOBAL variables which we can
# define outside this makefile.

# 
include require_0.mk


ifndef EPICSVERSION


include require_1.mk

else # EPICSVERSION

include require_2.mk

endif # EPICSVERSION defined
