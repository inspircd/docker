#!/bin/sh
########################################
###                                  ###
### DON'T EDIT THIS FILE AFTER BUILD ###
###                                  ###
###    USE ENVIRONMENT VARIABLES     ###
###              INSTEAD             ###
###                                  ###
########################################



# Prevent breaking changes
if [ "$INSP_OPER_PASSWORD_HASH" = "" ] && [ "$INSP_OPER_PASSWORD" != "" ]; then
    INSP_OPER_PASSWORD_HASH="$INSP_OPER_PASSWORD"
fi

# Define variables
cat <<EOF
<define name="operName" value="${INSP_OPER_NAME:-oper}">
<define name="operPassword" value="${INSP_OPER_PASSWORD_HASH}">
<define name="operFingerprint" value="${INSP_OPER_FINGERPRINT}">
<define name="operAutologin" value="${INSP_OPER_AUTOLOGIN:-no}">
<define name="operSSLOnly" value="${INSP_OPER_SSLONLY:-yes}">
<define name="operHash" value="${INSP_OPER_HASH:-hmac-sha256}">
<define name="operHost" value="${INSP_OPER_HOST:-*@*}">
EOF

# Default configs
cat <<EOF
#-#-#-#-#-#-#-#-#-#-#-#-  CLASS CONFIGURATION   -#-#-#-#-#-#-#-#-#-#-#-
#                                                                     #
#   Classes are a group of commands which are grouped together and    #
#   given a unique name. They're used to define which commands        #
#   are available to certain types of Operators.                      #
#                                                                     #
#                                                                     #
#  Note: It is possible to make a class which covers all available    #
#  commands. To do this, specify commands="*". This is not really     #
#  recommended, as it negates the whole purpose of the class system,  #
#  however it is provided for fast configuration (e.g. in test nets). #
#                                                                     #

<class
     name="Shutdown"

     # commands: Oper-only commands that opers of this class can run.
     commands="DIE RESTART REHASH LOADMODULE UNLOADMODULE RELOADMODULE GLOADMODULE GUNLOADMODULE GRELOADMODULE"

     # privs: Special privileges that users with this class may utilise.
     #  VIEWING:
     #   - channels/auspex: allows opers with this priv to see more detail about channels than normal users.
     #   - users/auspex: allows opers with this priv to view more details about users than normal users, e.g. real host and IP.
     #   - servers/auspex: allows opers with this priv to see more detail about server information than normal users.
     # ACTIONS:
     #   - users/mass-message: allows opers with this priv to PRIVMSG and NOTICE to a server mask (e.g. NOTICE $*)
     #   - channels/high-join-limit: allows opers with this priv to join <channels:opers> total channels instead of <channels:users> total channels.
     # PERMISSIONS:
     #   - users/flood/no-fakelag: prevents opers from being penalized with fake lag for flooding (*NOTE)
     #   - users/flood/no-throttle: allows opers with this priv to send commands without being throttled (*NOTE)
     #   - users/flood/increased-buffers: allows opers with this priv to send and receive data without worrying about being disconnected for exceeding limits (*NOTE)
     #
     # *NOTE: These privs are potentially dangerous, as they grant users with them the ability to hammer your server's CPU/RAM as much as they want, essentially.
     privs="users/auspex channels/auspex servers/auspex users/mass-message channels/high-join-limit users/flood/no-throttle users/flood/increased-buffers"

     # usermodes: Oper-only usermodes that opers with this class can use.
     usermodes="*"

     # chanmodes: Oper-only channel modes that opers with this class can use.
     chanmodes="*">

<class name="SACommands" commands="SAJOIN SAPART SANICK SAQUIT SATOPIC SAKICK SAMODE OJOIN">
<class name="ServerLink" commands="CONNECT SQUIT RCONNECT RSQUIT MKPASSWD ALLTIME SWHOIS JUMPSERVER LOCKSERV UNLOCKSERV" usermodes="*" chanmodes="*" privs="servers/auspex">
<class name="BanControl" commands="KILL GLINE KLINE ZLINE QLINE ELINE TLINE RLINE CHECK NICKLOCK NICKUNLOCK SHUN CLONES CBAN CLOSE" usermodes="*" chanmodes="*">
<class name="OperChat" commands="WALLOPS GLOBOPS" usermodes="*" chanmodes="*" privs="users/mass-message">
<class name="HostCloak" commands="SETHOST SETIDENT SETIDLE CHGNAME CHGHOST CHGIDENT" usermodes="*" chanmodes="*" privs="users/auspex">


#-#-#-#-#-#-#-#-#-#-#-#-  OPERATOR COMPOSITION   -#-#-#-#-#-#-#-#-#-#-#
#                                                                     #
#   This is where you specify which types of operators you have on    #
#   your server, as well as the commands they are allowed to use.     #
#   This works alongside with the classes specified above.            #
#                                                                     #

<type
    # name: Name of type. Used in actual server operator accounts below.
    # Cannot contain spaces. If you would like a space, use
    # the _ character instead and it will translate to a space on whois.
    name="NetAdmin"

    # classes: Classes (blocks above) that this type belongs to.
    classes="SACommands OperChat BanControl HostCloak Shutdown ServerLink"

    # vhost: Host opers of this type get when they log in (oper up). This is optional.
    vhost="netadmin&netsuffix;"

    # modes: User modes besides +o that are set on an oper of this type
    # when they oper up. Used for snomasks and other things.
    # Requires that m_opermodes.so be loaded.
    modes="+s +cCqQ">

#-#-#-#-#-#-#-#-#-#-#-  OPERATOR CONFIGURATION   -#-#-#-#-#-#-#-#-#-#-#
#                                                                     #
#   Opers are defined here. This is a very important section.         #
#   Remember to only make operators out of trustworthy people.        #
#                                                                     #
EOF

# Generate oper with Fingerprint
if [ "${INSP_OPER_FINGERPRINT}" != "" ]; then
cat <<EOF
# Operator with a plaintext password and no comments, for easy copy & paste.
<oper
      # name: Oper login that is used to oper up (/oper name password).
      # Remember: This is case sensitive.
      name="&operName;"

      # ** ADVANCED ** This option is disabled by default.
      # fingerprint: When using the m_sslinfo module, you may specify
      # a key fingerprint here. This can be obtained by using the /sslinfo
      # command while the module is loaded, and is also noticed on connect.
      # This enhances security by verifying that the person opering up has
      # a matching SSL client certificate, which is very difficult to
      # forge (impossible unless preimage attacks on the hash exist).
      # If m_sslinfo isn't loaded, this option will be ignored.
      fingerprint="&operFingerprint;"

      # autologin: If an SSL fingerprint for this oper is specified, you can
      # have the oper block automatically log in. This moves all security of the
      # oper block to the protection of the client certificate, so be sure that
      # the private key is well-protected! Requires m_sslinfo.
      autologin="&operAutologin;"

      # host: What hostnames and IPs are allowed to use this operator account.
      # Multiple options can be separated by spaces and CIDRs are allowed.
      # You can use just * or *@* for this section, but it is not recommended
      # for security reasons.
      host="&operHost;"

      nopassword="yes"
      sslonly="&operSSLOnly;"
      type="NetAdmin">
EOF

# Generate oper with password
elif [ "${INSP_OPER_PASSWORD_HASH}" != "" ]; then

cat <<EOF
# Operator with a hashed password. It is highly recommended to use hashed passwords.
<oper
      # name: Oper login that is used to oper up (/oper name password).
      # Remember: This is case sensitive.
      name="&operName;"

      # hash: What hash this password is hashed with.
      # Requires the module for selected hash (m_md5.so, m_sha256.so
      # or m_ripemd160.so) be loaded and the password hashing module
      # (m_password_hash.so) loaded.
      # Options here are: "md5", "sha256" and "ripemd160", or one of
      # these prefixed with "hmac-", e.g.: "hmac-sha256".
      # Create hashed passwords with: /mkpasswd <hash> <password>
      hash="&operHash;"

      # password: A hash of the password (see above option) hashed
      # with /mkpasswd <hash> <password>. See m_password_hash in modules.conf
      # for more information about password hashing.
      password="&operPassword;"

      # host: What hostnames and IPs are allowed to use this operator account.
      # Multiple options can be separated by spaces and CIDRs are allowed.
      # You can use just * or *@* for this section, but it is not recommended
      # for security reasons.
      host="&operHost;"

      # sslonly: If on, this oper can only oper up if they're using a SSL connection.
      # Setting this option adds a decent bit of security. Highly recommended
      # if the oper is on wifi, or specifically, unsecured wifi. Note that it
      # is redundant to specify this option if you specify a fingerprint.
      # This setting only takes effect if m_sslinfo is loaded.
      sslonly="&operSSLOnly;"

      # type: Which type of operator this person is; see the block
      # above for the list of types. NOTE: This is case-sensitive as well.
      type="NetAdmin">
EOF

fi
