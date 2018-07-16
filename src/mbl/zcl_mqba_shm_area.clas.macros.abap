*"* use this source file for any macro definitions you need
*"* in the implementation part of the class

DEFINE mc_set_shm_client.

  if client is supplied.
    l_client = client.
    l_client_supplied = abap_true.
  else.
    l_client = cl_abap_syst=>get_client( ).
  endif.

END-OF-DEFINITION.

DEFINE mc_set_shm_client_attach_only.

  l_client = cl_abap_syst=>get_client( ).

END-OF-DEFINITION.

