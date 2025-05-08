resource test2 {
  protocol C;
  device /dev/drbd2;
  disk /dev/xvdd;
  meta-disk internal;
  startup {
    wfc-timeout 1;
    degr-wfc-timeout 1;
  }
  disk {
    # resync configuration for a local gigabit network link
    #c-plan-ahead 1;
    #c-fill-target 24M;
    #c-max-rate 110M;
    #c-min-rate 10M;
    # trying to get things faster on 10gig
    c-plan-ahead 10;
    c-fill-target 240M;
    c-max-rate 1100M;
    c-min-rate 10M;

    disk-barrier no;
    disk-flushes no;

  }
  net {
    max-buffers 36k;
    sndbuf-size 1024k;
    rcvbuf-size 2048k;

    # set to "yes" to enable migration
    #
    # NOTE: Doing this also gives users the ability to hose the heck out of our
    #       drbd volume (i.e., xl create will successfully promote both hosts
    #       to Primary if you ask it to... which is bad).
    allow-two-primaries no;
    # split-brain autocorrect policy
    after-sb-0pri discard-zero-changes;
    after-sb-1pri discard-secondary;
    after-sb-2pri disconnect;
  }
  on gimli {
    address 10.37.20.43:7802;
    node-id 0;
  }
  on legolas {
    address 10.37.20.44:7802;
    node-id 1;
  }
  on boromir {
    address 10.37.20.45:7802;
    node-id 2;
  }
  connection-mesh {
    hosts gimli legolas boromir;
  }
}


#resource sim1-U {
#  protocol A;
#  device /dev/drbd41;
#  disk {
#    # resync configuration for a local gigabit network link
#    c-plan-ahead 1;
#    c-fill-target 24M;
#    c-max-rate 110M;
#    c-min-rate 10M;
#  }
#
#  stacked-on-top-of vtapes {
#    address 192.168.42.156:7842; # merry.neo
#  }
#
#  on glaurung {
#    disk /dev/vg00/vm_sim1;
#    address 192.168.42.97:7842; # glaurung.neo
#    meta-disk internal;
#  }
#}
