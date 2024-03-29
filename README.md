# Anticheat

# DO NOT USE: IS OLD UNSTABLE VERSION 
# -- DEPRECATED -- 

```
------------------------------                --------------------------------------------
-  ClientBlock               -                - 1. Calculate and save function signature -
-  1. Critical Functions     -                --------------------------------------------
-  2. Critical Binares       -     -------->                                                 --> Result
-  3. Critical JitEvents     -                --------------------------------------------
-  4. Network validation     -                - 2. Check knowed binary signature         -    
------------------------------                -------------------------------------------- 

- Critical JitEvents - 

1. Check lua events: "add new function" or "refresh all code"
---> Store statictics 

4. Network Validation 

----------Server------------      ----SendPacket-----     ------Client--------
- 1.Generate XOR Password  - -->  -  {XOR PASSWORD} - --> - Store Password   -
----------------------------      -------------------     --------------------
/ 
/
/ 
/
/ -> Server has been generaeted random password with {XOR PASSWORD} 
/
/
/
/
-----------Client-----------     ----SendPacket-------     ------Server--------------------------------------------------------------------
- 2.Decrypt password:      - --> - {Decrypted Pass}  -     - 1. Check password: if equal -> SetBool(UserValidated) else KickPlayer        - 
-                          -     - {Other statistic} - --> - 2. If Password validated then check statistics;                              -
-                          -     -                   -     -     if exists bad signature or undefined                                     -
-                          -     -                   -     -     behavour -> Ban player                                                   -
----------------------------     ---------------------     --------------------------------------------------------------------------------
```                                             

Это лишь краткий пример. Делал давно уже не помню, как точно он работает

