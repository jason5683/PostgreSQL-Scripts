# Check for Duplicate Indexes

Unneeded indexes, such as duplicates, take up disk space, require time to vacuum, and slow down update and insert operations

This script checks for duplicate indexes in a more user-friendly fashion than our previous ones.  Just run it in the database you want to check.

Results are reported as a "duplicate index" and an "encompassing index." The theory is that you can drop the duplicate index in favor of the encompassing index.

Do not just follow this blindly, though!  For example, if you have two identical indexes, they'll appear in the report as a pair twice: once with one as the duplicate and the other as encompassing, and then the reverse. (If there are three, the report shows all possible pairs.) Be sure you leave one!

Always review before dropping, and test in development or staging before dropping from your production environment.

Some notes:

* We recommend enabling extended output in psql with \\x for better readability.

* This check skips:

  * `pg_*` tables
  * Any index that contains an expression, since those are hard to check for duplicates. Those should be checked manually.

* A primary key index will never be marked as a "duplicate."

* Review results for indexes on Foreign Keys and referenced columns. For referenced columns, dropping the duplicate index is not usually a problem, but for Foreign Keys you may have a tradeoff between query performance _vs_ INSERT, UPDATE, DELETE performance.

* Your statistics may show that the "duplicate" index is being used;  this is normal and not an argument to keep the duplicate.  Postgres should switch to using the encompassing index once the duplicate is gone.

* A lot of folks react to this report with "How could this happen!?!"  This is not a personal failing; if you're using an ORM for schema management, that's probably the source of most if not all of the duplicates.  You may have to do some manual wrangling with your ORM to prevent them from re-occurring.

## Example output

```
-[ RECORD 1 ]-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
table                         | public.foo
dup index                     | index_foo_on_bar
dup index definition          | CREATE INDEX index_foo_on_bar ON public.foo USING btree (bar)
dup index attributes          | 2
encompassing index            | index_foo_on_bar_and_baz
encompassing index definition | CREATE INDEX index_foo_on_bar_and_baz ON public.foo USING btree (bar, baz)
enc index attributes          | 2 3
```

Since the multi-column index `index_foo_on_bar_and_baz` would be used for searches only on the `bar` column, we can drop the individual index `index_foo_on_bar`.

```
-[ RECORD 2 ]-----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
table                         | public.movies
dup index                     | index_movies_on_title
dup index definition          | CREATE INDEX index_movies_on_title ON public.movies USING btree (title)
dup index attributes          | 2
encompassing index            | index_movies_on_title_and_studio
encompassing index definition | CREATE UNIQUE INDEX index_movies_on_title_and_studio ON public.movies USING btree (title, studio)
enc index attributes          | 2 3
```

Same as example #1: the multi-column index `index_movies_on_title_and_studio` would be used for searches on just the `title` column, we can drop the individual index `index_movies_on_title`.

This next example shows what happens with multiple duplicate indexes:

```ateb    obc    sms_jobq    sms_jobq_pkey    100    28    28.266    25.172    199028579
ateb    pmap    pmaptoken    pk_pmaptoken    100    22    21.836    140.258    280771305
ateb    obc    jobq    jobq_pkey    99    13    13.539    112.641    124224609
ateb    pmap    interventionalertclaim118    pmap_interventionalertclaim118_pkey    97    48    49.820    7.414    1969792
ateb    obc    contact_block    contact_block_pkey    96    42    43.164    139.555    433705515
ateb    pmap    pmapuserrole    pk_pmapuserrole    95    24    24.938    4.398    0
ateb    pmap    pmapuserstore    pk_pmapuserstore    92    19    21.094    5.727    0
ateb    pmap    interventionalertclaim_extra    pmap_interventionalertclaim_extra_pkey    90    41    46.023    17.805    1957564
ateb    obc    contact_block    contact_block_campaign_id_client_id_idx    88    11    12.461    139.555    56916189
ateb    public    rxfilldata_parent    ix_merge8_daily    87    297    343.086    1804.586    18889
ateb    amc    campaignpatients    campaigngroupid_crm_status_idx    86    9273    10784.258    69905.945    4522
ateb    clinic    clinicmessageconfigurationstatus    clinicmessageconfigurationstatus_pkey    86    25    29.438    884.656    0
ateb    patient    patientcontact_extra    patientcontact_extra_atebpatientid_clientid_patientcontactm_idx    81    2960    3634.172    5341.617    2287842140
ateb    amc    campaignobcresults    campaignobcresultlookup_idx    80    918    1143.227    5044.398    60127
ateb    obc    phone_item    ix_phone_item_2    78    1109    1422.188    2370.148    1761694
ateb    mdfaudit    nullfieldstatistic    pk_nullfieldstatistic    78    15646    20073.867    91013.742    0
ateb    amc    campaignpatients    campaigngroupid_clientid_crm_status_externalpatientid_idx    78    9973    12790.281    69905.945    327
ateb    amc    campaignpatients    campaigngroupid_clientid_patientnamefirst_patob_lfilldate_idx    77    9534    12350.648    69905.945    32389550
ateb    amc    campaignpatients    campaigngroupid_clientid_patientnamefirst_patientdob_lastfillda    77    9534    12350.781    69905.945    0
ateb    mdfaudit    message    message_pkey    77    170    220.219    12414.828    2007407
ateb    pmap    ifdatachange    ifdatachange_new_pkey    76    1148    1505.672    2760.625    112628975
ateb    amc    campaignpatients    campaigngroupid_clientid_externalpatientid_lastfilldate_idx    76    8927    11744.563    69905.945    35447846
ateb    obc    sms_item    sms_item_blk_item_2    75    2319    3099.328    6434.844    16987432
ateb    amc    campaignsdfdatarecs    campaignsdfdatarecs_pkey    74    36    48.555    407.398    12051
ateb    obcresult    refillpostingrx    refillpostingrx_refillpostingid_postedtimestamp_idx    73    4551    6225.531    12084.891    75053561629
ateb    obc    pushnotification_item    pushnotification_item_pkey    73    298    406.008    2361.414    156954568
ateb    identity    token    token_pkey    72    2921    4042.148    3393.680    22970113
ateb    amc    campaignpatients    campaignpatientlookup_idx    71    7097    9959.492    69905.945    707381916
ateb    pmap    medsyncresponse17    pmap_medsyncresponse17_pkey    71    35    49.797    266.953    8856845
ateb    amc    campaignpatients    clientid_campaigngroupid_storeuid    71    6871    9732.328    69905.945    74459
ateb    clinic    clinicmessages    clinicmessages_clientid_clinicid_idx    69    131    189.281    4282.367    247406
ateb    pmap    interventionalertclaim7    pmap_interventionalertclaim7_pkey    68    28    40.891    47.766    1953029
ateb    pmap    interventionalert7    pmap_interventionalert7_pkey    66    2523    3798.195    12802.070    59161580
ateb    clinic    patient    patient_clientid_addressid_idx    66    91    137.148    357.320    21169
ateb    obc    phone_item    phone_item_pkey    65    589    901.766    2370.148    806620284
ateb    pmap    medsyncresponse_extra    medsyncresponse_extra_clientid_atebpatientid_idx    65    24    37.188    1219.484    577826936
ateb    obc    phone_item    phone_item_blk_item_2    65    589    902.383    2370.148    21185802
ateb    obcresult    refillpostingrx    refillpostingrx_refillpostingid_rxnum_idx    65    3836    5936.633    12084.891    38843826847
ateb    pmap    medsyncresponse7    pmap_medsyncresponse7_pkey    64    120    187.836    912.758    9018052
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx1    64    7937    12314.633    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx2    64    7949    12327.242    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx3    64    7940    12317.430    69905.945    0
ateb    pmap    medsyncresponse_extra    pmap_medsyncresponse_extra_pkey    64    146    228.422    1219.484    9879515
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx4    64    7940    12317.508    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status_l_idx    64    7937    12315.148    69905.945    0
ateb    pmap    interventionalert17    pmap_interventionalert17_pkey    63    1130    1788.492    6297.180    51277727
ateb    pmap    interventionalert_extra    pmap_interventionalert_extra_pkey    63    3223    5114.078    18441.430    64589391
ateb    amc    campaignpatients    campaigngroupid_rxnbr_storeuid_rx_status_lastfilldate_idx    63    7559    11937.172    69905.945    70621814
ateb    pmap    archivepatientparticipation2    pmap_archivepatientparticipation2_pkey    61    35    57.094    256.828    0
ateb    pmap    medsyncresponse118    pmap_medsyncresponse118_pkey    60    481    807.719    4047.250    9997006
ateb    obc    sms_item    sms_item_pkey    60    1188    1967.875    6434.844    1036446418
ateb    pmap    archivepatientparticipation22    pmap_archivepatientparticipation22_pkey    58    24    41.047    188.602    0
ateb    obc    generated_rpt    generated_rpt_pkey    57    11    19.109    110.039    11469125
ateb    public    ignoreimportfile    ignoreimportfile_clientid_importsourcefileid_idx    57    18    30.641    155.758    36178
ateb    pmap    archivepatientparticipation17    pmap_archivepatientparticipation17_pkey    57    70    123.578    533.914    0
ateb    amc    campaignpatients    campaignpatient_store_rxbr_idx    56    5559    9938.563    69905.945    17369904
ateb    obc    contact_param    contact_param_block_id_item_id_tag_cp_grp_key    56    13831    24845.633    31314.688    1071465565
ateb    patient    patientcontact_extra    patient_patientcontact_extra_pkey    56    1041    1875.203    5341.617    46513795
ateb    campaign    contactrequestschedule    contactrequestschedule_pkey    56    14    24.727    51.016    9463
ateb    amc    patientcontactpreferences    patientcontactpreferences_origpatientphonenbr_patientdob_idx    56    64    115.359    375.836    335242842
ateb    patient    patientdemographic_extra    patient_patientdemographic_extra_pkey    55    1025    1855.914    4952.602    49097753
ateb    patient    patientcontact2    patient_patientcontact2_pkey    55    174    313.633    831.813    13403169
ateb    patient    patientaddress_extra    patient_patientaddress_extra_pkey    55    1027    1857.781    6519.359    49092983
ateb    clinic    appointment    appointment_clientid_clinicid_idx    55    57    103.039    698.297    228467793
ateb    patient    patientname_extra    patient_patientname_extra_pkey    55    1035    1865.250    6166.617    49092893
ateb    campaign    archivepatientlog    pk_archivepatientlog_1    55    18    32.375    217.813    0
ateb    patient    patientrx_extra    patientrx_extra_clientid_storeid_atebpatientid_idx    53    4870    9275.477    24503.391    149881567
ateb    externaldata    membership    membership_pkey    52    21    40.641    110.000    14090226
ateb    obcresult    refillpostingrx    refillpostingrx_pkey    51    2152    4252.258    12084.891    33436460
ateb    obc    phone_lookup_log    phone_lookup_log_phone_number_client_id_idx    51    86    168.078    431.555    0
ateb    patient    patientname7    patient_patientname7_pkey    51    212    418.891    1140.344    9915832ateb    obc    sms_jobq    sms_jobq_pkey    100    28    28.266    25.172    199028579
ateb    pmap    pmaptoken    pk_pmaptoken    100    22    21.836    140.258    280771305
ateb    obc    jobq    jobq_pkey    99    13    13.539    112.641    124224609
ateb    pmap    interventionalertclaim118    pmap_interventionalertclaim118_pkey    97    48    49.820    7.414    1969792
ateb    obc    contact_block    contact_block_pkey    96    42    43.164    139.555    433705515
ateb    pmap    pmapuserrole    pk_pmapuserrole    95    24    24.938    4.398    0
ateb    pmap    pmapuserstore    pk_pmapuserstore    92    19    21.094    5.727    0
ateb    pmap    interventionalertclaim_extra    pmap_interventionalertclaim_extra_pkey    90    41    46.023    17.805    1957564
ateb    obc    contact_block    contact_block_campaign_id_client_id_idx    88    11    12.461    139.555    56916189
ateb    public    rxfilldata_parent    ix_merge8_daily    87    297    343.086    1804.586    18889
ateb    amc    campaignpatients    campaigngroupid_crm_status_idx    86    9273    10784.258    69905.945    4522
ateb    clinic    clinicmessageconfigurationstatus    clinicmessageconfigurationstatus_pkey    86    25    29.438    884.656    0
ateb    patient    patientcontact_extra    patientcontact_extra_atebpatientid_clientid_patientcontactm_idx    81    2960    3634.172    5341.617    2287842140
ateb    amc    campaignobcresults    campaignobcresultlookup_idx    80    918    1143.227    5044.398    60127
ateb    obc    phone_item    ix_phone_item_2    78    1109    1422.188    2370.148    1761694
ateb    mdfaudit    nullfieldstatistic    pk_nullfieldstatistic    78    15646    20073.867    91013.742    0
ateb    amc    campaignpatients    campaigngroupid_clientid_crm_status_externalpatientid_idx    78    9973    12790.281    69905.945    327
ateb    amc    campaignpatients    campaigngroupid_clientid_patientnamefirst_patob_lfilldate_idx    77    9534    12350.648    69905.945    32389550
ateb    amc    campaignpatients    campaigngroupid_clientid_patientnamefirst_patientdob_lastfillda    77    9534    12350.781    69905.945    0
ateb    mdfaudit    message    message_pkey    77    170    220.219    12414.828    2007407
ateb    pmap    ifdatachange    ifdatachange_new_pkey    76    1148    1505.672    2760.625    112628975
ateb    amc    campaignpatients    campaigngroupid_clientid_externalpatientid_lastfilldate_idx    76    8927    11744.563    69905.945    35447846
ateb    obc    sms_item    sms_item_blk_item_2    75    2319    3099.328    6434.844    16987432
ateb    amc    campaignsdfdatarecs    campaignsdfdatarecs_pkey    74    36    48.555    407.398    12051
ateb    obcresult    refillpostingrx    refillpostingrx_refillpostingid_postedtimestamp_idx    73    4551    6225.531    12084.891    75053561629
ateb    obc    pushnotification_item    pushnotification_item_pkey    73    298    406.008    2361.414    156954568
ateb    identity    token    token_pkey    72    2921    4042.148    3393.680    22970113
ateb    amc    campaignpatients    campaignpatientlookup_idx    71    7097    9959.492    69905.945    707381916
ateb    pmap    medsyncresponse17    pmap_medsyncresponse17_pkey    71    35    49.797    266.953    8856845
ateb    amc    campaignpatients    clientid_campaigngroupid_storeuid    71    6871    9732.328    69905.945    74459
ateb    clinic    clinicmessages    clinicmessages_clientid_clinicid_idx    69    131    189.281    4282.367    247406
ateb    pmap    interventionalertclaim7    pmap_interventionalertclaim7_pkey    68    28    40.891    47.766    1953029
ateb    pmap    interventionalert7    pmap_interventionalert7_pkey    66    2523    3798.195    12802.070    59161580
ateb    clinic    patient    patient_clientid_addressid_idx    66    91    137.148    357.320    21169
ateb    obc    phone_item    phone_item_pkey    65    589    901.766    2370.148    806620284
ateb    pmap    medsyncresponse_extra    medsyncresponse_extra_clientid_atebpatientid_idx    65    24    37.188    1219.484    577826936
ateb    obc    phone_item    phone_item_blk_item_2    65    589    902.383    2370.148    21185802
ateb    obcresult    refillpostingrx    refillpostingrx_refillpostingid_rxnum_idx    65    3836    5936.633    12084.891    38843826847
ateb    pmap    medsyncresponse7    pmap_medsyncresponse7_pkey    64    120    187.836    912.758    9018052
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx1    64    7937    12314.633    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx2    64    7949    12327.242    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx3    64    7940    12317.430    69905.945    0
ateb    pmap    medsyncresponse_extra    pmap_medsyncresponse_extra_pkey    64    146    228.422    1219.484    9879515
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx4    64    7940    12317.508    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status_l_idx    64    7937    12315.148    69905.945    0
ateb    pmap    interventionalert17    pmap_interventionalert17_pkey    63    1130    1788.492    6297.180    51277727
ateb    pmap    interventionalert_extra    pmap_interventionalert_extra_pkey    63    3223    5114.078    18441.430    64589391
ateb    amc    campaignpatients    campaigngroupid_rxnbr_storeuid_rx_status_lastfilldate_idx    63    7559    11937.172    69905.945    70621814
ateb    pmap    archivepatientparticipation2    pmap_archivepatientparticipation2_pkey    61    35    57.094    256.828    0
ateb    pmap    medsyncresponse118    pmap_medsyncresponse118_pkey    60    481    807.719    4047.250    9997006
ateb    obc    sms_item    sms_item_pkey    60    1188    1967.875    6434.844    1036446418
ateb    pmap    archivepatientparticipation22    pmap_archivepatientparticipation22_pkey    58    24    41.047    188.602    0
ateb    obc    generated_rpt    generated_rpt_pkey    57    11    19.109    110.039    11469125
ateb    public    ignoreimportfile    ignoreimportfile_clientid_importsourcefileid_idx    57    18    30.641    155.758    36178
ateb    pmap    archivepatientparticipation17    pmap_archivepatientparticipation17_pkey    57    70    123.578    533.914    0
ateb    amc    campaignpatients    campaignpatient_store_rxbr_idx    56    5559    9938.563    69905.945    17369904
ateb    obc    contact_param    contact_param_block_id_item_id_tag_cp_grp_key    56    13831    24845.633    31314.688    1071465565
ateb    patient    patientcontact_extra    patient_patientcontact_extra_pkey    56    1041    1875.203    5341.617    46513795
ateb    campaign    contactrequestschedule    contactrequestschedule_pkey    56    14    24.727    51.016    9463
ateb    amc    patientcontactpreferences    patientcontactpreferences_origpatientphonenbr_patientdob_idx    56    64    115.359    375.836    335242842
ateb    patient    patientdemographic_extra    patient_patientdemographic_extra_pkey    55    1025    1855.914    4952.602    49097753
ateb    patient    patientcontact2    patient_patientcontact2_pkey    55    174    313.633    831.813    13403169
ateb    patient    patientaddress_extra    patient_patientaddress_extra_pkey    55    1027    1857.781    6519.359    49092983
ateb    clinic    appointment    appointment_clientid_clinicid_idx    55    57    103.039    698.297    228467793
ateb    patient    patientname_extra    patient_patientname_extra_pkey    55    1035    1865.250    6166.617    49092893
ateb    campaign    archivepatientlog    pk_archivepatientlog_1    55    18    32.375    217.813    0
ateb    patient    patientrx_extra    patientrx_extra_clientid_storeid_atebpatientid_idx    53    4870    9275.477    24503.391    149881567
ateb    externaldata    membership    membership_pkey    52    21    40.641    110.000    14090226
ateb    obcresult    refillpostingrx    refillpostingrx_pkey    51    2152    4252.258    12084.891    33436460
ateb    obc    phone_lookup_log    phone_lookup_log_phone_number_client_id_idx    51    86    168.078    431.555    0
ateb    patient    patientname7    patient_patientname7_pkey    51    212    418.891    1140.344    9915832ateb    obc    sms_jobq    sms_jobq_pkey    100    28    28.266    25.172    199028579
ateb    pmap    pmaptoken    pk_pmaptoken    100    22    21.836    140.258    280771305
ateb    obc    jobq    jobq_pkey    99    13    13.539    112.641    124224609
ateb    pmap    interventionalertclaim118    pmap_interventionalertclaim118_pkey    97    48    49.820    7.414    1969792
ateb    obc    contact_block    contact_block_pkey    96    42    43.164    139.555    433705515
ateb    pmap    pmapuserrole    pk_pmapuserrole    95    24    24.938    4.398    0
ateb    pmap    pmapuserstore    pk_pmapuserstore    92    19    21.094    5.727    0
ateb    pmap    interventionalertclaim_extra    pmap_interventionalertclaim_extra_pkey    90    41    46.023    17.805    1957564
ateb    obc    contact_block    contact_block_campaign_id_client_id_idx    88    11    12.461    139.555    56916189
ateb    public    rxfilldata_parent    ix_merge8_daily    87    297    343.086    1804.586    18889
ateb    amc    campaignpatients    campaigngroupid_crm_status_idx    86    9273    10784.258    69905.945    4522
ateb    clinic    clinicmessageconfigurationstatus    clinicmessageconfigurationstatus_pkey    86    25    29.438    884.656    0
ateb    patient    patientcontact_extra    patientcontact_extra_atebpatientid_clientid_patientcontactm_idx    81    2960    3634.172    5341.617    2287842140
ateb    amc    campaignobcresults    campaignobcresultlookup_idx    80    918    1143.227    5044.398    60127
ateb    obc    phone_item    ix_phone_item_2    78    1109    1422.188    2370.148    1761694
ateb    mdfaudit    nullfieldstatistic    pk_nullfieldstatistic    78    15646    20073.867    91013.742    0
ateb    amc    campaignpatients    campaigngroupid_clientid_crm_status_externalpatientid_idx    78    9973    12790.281    69905.945    327
ateb    amc    campaignpatients    campaigngroupid_clientid_patientnamefirst_patob_lfilldate_idx    77    9534    12350.648    69905.945    32389550
ateb    amc    campaignpatients    campaigngroupid_clientid_patientnamefirst_patientdob_lastfillda    77    9534    12350.781    69905.945    0
ateb    mdfaudit    message    message_pkey    77    170    220.219    12414.828    2007407
ateb    pmap    ifdatachange    ifdatachange_new_pkey    76    1148    1505.672    2760.625    112628975
ateb    amc    campaignpatients    campaigngroupid_clientid_externalpatientid_lastfilldate_idx    76    8927    11744.563    69905.945    35447846
ateb    obc    sms_item    sms_item_blk_item_2    75    2319    3099.328    6434.844    16987432
ateb    amc    campaignsdfdatarecs    campaignsdfdatarecs_pkey    74    36    48.555    407.398    12051
ateb    obcresult    refillpostingrx    refillpostingrx_refillpostingid_postedtimestamp_idx    73    4551    6225.531    12084.891    75053561629
ateb    obc    pushnotification_item    pushnotification_item_pkey    73    298    406.008    2361.414    156954568
ateb    identity    token    token_pkey    72    2921    4042.148    3393.680    22970113
ateb    amc    campaignpatients    campaignpatientlookup_idx    71    7097    9959.492    69905.945    707381916
ateb    pmap    medsyncresponse17    pmap_medsyncresponse17_pkey    71    35    49.797    266.953    8856845
ateb    amc    campaignpatients    clientid_campaigngroupid_storeuid    71    6871    9732.328    69905.945    74459
ateb    clinic    clinicmessages    clinicmessages_clientid_clinicid_idx    69    131    189.281    4282.367    247406
ateb    pmap    interventionalertclaim7    pmap_interventionalertclaim7_pkey    68    28    40.891    47.766    1953029
ateb    pmap    interventionalert7    pmap_interventionalert7_pkey    66    2523    3798.195    12802.070    59161580
ateb    clinic    patient    patient_clientid_addressid_idx    66    91    137.148    357.320    21169
ateb    obc    phone_item    phone_item_pkey    65    589    901.766    2370.148    806620284
ateb    pmap    medsyncresponse_extra    medsyncresponse_extra_clientid_atebpatientid_idx    65    24    37.188    1219.484    577826936
ateb    obc    phone_item    phone_item_blk_item_2    65    589    902.383    2370.148    21185802
ateb    obcresult    refillpostingrx    refillpostingrx_refillpostingid_rxnum_idx    65    3836    5936.633    12084.891    38843826847
ateb    pmap    medsyncresponse7    pmap_medsyncresponse7_pkey    64    120    187.836    912.758    9018052
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx1    64    7937    12314.633    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx2    64    7949    12327.242    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx3    64    7940    12317.430    69905.945    0
ateb    pmap    medsyncresponse_extra    pmap_medsyncresponse_extra_pkey    64    146    228.422    1219.484    9879515
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx4    64    7940    12317.508    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status_l_idx    64    7937    12315.148    69905.945    0
ateb    pmap    interventionalert17    pmap_interventionalert17_pkey    63    1130    1788.492    6297.180    51277727
ateb    pmap    interventionalert_extra    pmap_interventionalert_extra_pkey    63    3223    5114.078    18441.430    64589391
ateb    amc    campaignpatients    campaigngroupid_rxnbr_storeuid_rx_status_lastfilldate_idx    63    7559    11937.172    69905.945    70621814
ateb    pmap    archivepatientparticipation2    pmap_archivepatientparticipation2_pkey    61    35    57.094    256.828    0
ateb    pmap    medsyncresponse118    pmap_medsyncresponse118_pkey    60    481    807.719    4047.250    9997006
ateb    obc    sms_item    sms_item_pkey    60    1188    1967.875    6434.844    1036446418
ateb    pmap    archivepatientparticipation22    pmap_archivepatientparticipation22_pkey    58    24    41.047    188.602    0
ateb    obc    generated_rpt    generated_rpt_pkey    57    11    19.109    110.039    11469125
ateb    public    ignoreimportfile    ignoreimportfile_clientid_importsourcefileid_idx    57    18    30.641    155.758    36178
ateb    pmap    archivepatientparticipation17    pmap_archivepatientparticipation17_pkey    57    70    123.578    533.914    0
ateb    amc    campaignpatients    campaignpatient_store_rxbr_idx    56    5559    9938.563    69905.945    17369904
ateb    obc    contact_param    contact_param_block_id_item_id_tag_cp_grp_key    56    13831    24845.633    31314.688    1071465565
ateb    patient    patientcontact_extra    patient_patientcontact_extra_pkey    56    1041    1875.203    5341.617    46513795
ateb    campaign    contactrequestschedule    contactrequestschedule_pkey    56    14    24.727    51.016    9463
ateb    amc    patientcontactpreferences    patientcontactpreferences_origpatientphonenbr_patientdob_idx    56    64    115.359    375.836    335242842
ateb    patient    patientdemographic_extra    patient_patientdemographic_extra_pkey    55    1025    1855.914    4952.602    49097753
ateb    patient    patientcontact2    patient_patientcontact2_pkey    55    174    313.633    831.813    13403169
ateb    patient    patientaddress_extra    patient_patientaddress_extra_pkey    55    1027    1857.781    6519.359    49092983
ateb    clinic    appointment    appointment_clientid_clinicid_idx    55    57    103.039    698.297    228467793
ateb    patient    patientname_extra    patient_patientname_extra_pkey    55    1035    1865.250    6166.617    49092893
ateb    campaign    archivepatientlog    pk_archivepatientlog_1    55    18    32.375    217.813    0
ateb    patient    patientrx_extra    patientrx_extra_clientid_storeid_atebpatientid_idx    53    4870    9275.477    24503.391    149881567
ateb    externaldata    membership    membership_pkey    52    21    40.641    110.000    14090226
ateb    obcresult    refillpostingrx    refillpostingrx_pkey    51    2152    4252.258    12084.891    33436460
ateb    obc    phone_lookup_log    phone_lookup_log_phone_number_client_id_idx    51    86    168.078    431.555    0
ateb    patient    patientname7    patient_patientname7_pkey    51    212    418.891    1140.344    9915832ateb    obc    sms_jobq    sms_jobq_pkey    100    28    28.266    25.172    199028579
ateb    pmap    pmaptoken    pk_pmaptoken    100    22    21.836    140.258    280771305
ateb    obc    jobq    jobq_pkey    99    13    13.539    112.641    124224609
ateb    pmap    interventionalertclaim118    pmap_interventionalertclaim118_pkey    97    48    49.820    7.414    1969792
ateb    obc    contact_block    contact_block_pkey    96    42    43.164    139.555    433705515
ateb    pmap    pmapuserrole    pk_pmapuserrole    95    24    24.938    4.398    0
ateb    pmap    pmapuserstore    pk_pmapuserstore    92    19    21.094    5.727    0
ateb    pmap    interventionalertclaim_extra    pmap_interventionalertclaim_extra_pkey    90    41    46.023    17.805    1957564
ateb    obc    contact_block    contact_block_campaign_id_client_id_idx    88    11    12.461    139.555    56916189
ateb    public    rxfilldata_parent    ix_merge8_daily    87    297    343.086    1804.586    18889
ateb    amc    campaignpatients    campaigngroupid_crm_status_idx    86    9273    10784.258    69905.945    4522
ateb    clinic    clinicmessageconfigurationstatus    clinicmessageconfigurationstatus_pkey    86    25    29.438    884.656    0
ateb    patient    patientcontact_extra    patientcontact_extra_atebpatientid_clientid_patientcontactm_idx    81    2960    3634.172    5341.617    2287842140
ateb    amc    campaignobcresults    campaignobcresultlookup_idx    80    918    1143.227    5044.398    60127
ateb    obc    phone_item    ix_phone_item_2    78    1109    1422.188    2370.148    1761694
ateb    mdfaudit    nullfieldstatistic    pk_nullfieldstatistic    78    15646    20073.867    91013.742    0
ateb    amc    campaignpatients    campaigngroupid_clientid_crm_status_externalpatientid_idx    78    9973    12790.281    69905.945    327
ateb    amc    campaignpatients    campaigngroupid_clientid_patientnamefirst_patob_lfilldate_idx    77    9534    12350.648    69905.945    32389550
ateb    amc    campaignpatients    campaigngroupid_clientid_patientnamefirst_patientdob_lastfillda    77    9534    12350.781    69905.945    0
ateb    mdfaudit    message    message_pkey    77    170    220.219    12414.828    2007407
ateb    pmap    ifdatachange    ifdatachange_new_pkey    76    1148    1505.672    2760.625    112628975
ateb    amc    campaignpatients    campaigngroupid_clientid_externalpatientid_lastfilldate_idx    76    8927    11744.563    69905.945    35447846
ateb    obc    sms_item    sms_item_blk_item_2    75    2319    3099.328    6434.844    16987432
ateb    amc    campaignsdfdatarecs    campaignsdfdatarecs_pkey    74    36    48.555    407.398    12051
ateb    obcresult    refillpostingrx    refillpostingrx_refillpostingid_postedtimestamp_idx    73    4551    6225.531    12084.891    75053561629
ateb    obc    pushnotification_item    pushnotification_item_pkey    73    298    406.008    2361.414    156954568
ateb    identity    token    token_pkey    72    2921    4042.148    3393.680    22970113
ateb    amc    campaignpatients    campaignpatientlookup_idx    71    7097    9959.492    69905.945    707381916
ateb    pmap    medsyncresponse17    pmap_medsyncresponse17_pkey    71    35    49.797    266.953    8856845
ateb    amc    campaignpatients    clientid_campaigngroupid_storeuid    71    6871    9732.328    69905.945    74459
ateb    clinic    clinicmessages    clinicmessages_clientid_clinicid_idx    69    131    189.281    4282.367    247406
ateb    pmap    interventionalertclaim7    pmap_interventionalertclaim7_pkey    68    28    40.891    47.766    1953029
ateb    pmap    interventionalert7    pmap_interventionalert7_pkey    66    2523    3798.195    12802.070    59161580
ateb    clinic    patient    patient_clientid_addressid_idx    66    91    137.148    357.320    21169
ateb    obc    phone_item    phone_item_pkey    65    589    901.766    2370.148    806620284
ateb    pmap    medsyncresponse_extra    medsyncresponse_extra_clientid_atebpatientid_idx    65    24    37.188    1219.484    577826936
ateb    obc    phone_item    phone_item_blk_item_2    65    589    902.383    2370.148    21185802
ateb    obcresult    refillpostingrx    refillpostingrx_refillpostingid_rxnum_idx    65    3836    5936.633    12084.891    38843826847
ateb    pmap    medsyncresponse7    pmap_medsyncresponse7_pkey    64    120    187.836    912.758    9018052
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx1    64    7937    12314.633    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx2    64    7949    12327.242    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx3    64    7940    12317.430    69905.945    0
ateb    pmap    medsyncresponse_extra    pmap_medsyncresponse_extra_pkey    64    146    228.422    1219.484    9879515
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status__idx4    64    7940    12317.508    69905.945    0
ateb    amc    campaignpatients    campaignpatients_campaigngroupid_rxnbr_storeuid_rx_status_l_idx    64    7937    12315.148    69905.945    0
ateb    pmap    interventionalert17    pmap_interventionalert17_pkey    63    1130    1788.492    6297.180    51277727
ateb    pmap    interventionalert_extra    pmap_interventionalert_extra_pkey    63    3223    5114.078    18441.430    64589391
ateb    amc    campaignpatients    campaigngroupid_rxnbr_storeuid_rx_status_lastfilldate_idx    63    7559    11937.172    69905.945    70621814
ateb    pmap    archivepatientparticipation2    pmap_archivepatientparticipation2_pkey    61    35    57.094    256.828    0
ateb    pmap    medsyncresponse118    pmap_medsyncresponse118_pkey    60    481    807.719    4047.250    9997006
ateb    obc    sms_item    sms_item_pkey    60    1188    1967.875    6434.844    1036446418
ateb    pmap    archivepatientparticipation22    pmap_archivepatientparticipation22_pkey    58    24    41.047    188.602    0
ateb    obc    generated_rpt    generated_rpt_pkey    57    11    19.109    110.039    11469125
ateb    public    ignoreimportfile    ignoreimportfile_clientid_importsourcefileid_idx    57    18    30.641    155.758    36178
ateb    pmap    archivepatientparticipation17    pmap_archivepatientparticipation17_pkey    57    70    123.578    533.914    0
ateb    amc    campaignpatients    campaignpatient_store_rxbr_idx    56    5559    9938.563    69905.945    17369904
ateb    obc    contact_param    contact_param_block_id_item_id_tag_cp_grp_key    56    13831    24845.633    31314.688    1071465565
ateb    patient    patientcontact_extra    patient_patientcontact_extra_pkey    56    1041    1875.203    5341.617    46513795
ateb    campaign    contactrequestschedule    contactrequestschedule_pkey    56    14    24.727    51.016    9463
ateb    amc    patientcontactpreferences    patientcontactpreferences_origpatientphonenbr_patientdob_idx    56    64    115.359    375.836    335242842
ateb    patient    patientdemographic_extra    patient_patientdemographic_extra_pkey    55    1025    1855.914    4952.602    49097753
ateb    patient    patientcontact2    patient_patientcontact2_pkey    55    174    313.633    831.813    13403169
ateb    patient    patientaddress_extra    patient_patientaddress_extra_pkey    55    1027    1857.781    6519.359    49092983
ateb    clinic    appointment    appointment_clientid_clinicid_idx    55    57    103.039    698.297    228467793
ateb    patient    patientname_extra    patient_patientname_extra_pkey    55    1035    1865.250    6166.617    49092893
ateb    campaign    archivepatientlog    pk_archivepatientlog_1    55    18    32.375    217.813    0
ateb    patient    patientrx_extra    patientrx_extra_clientid_storeid_atebpatientid_idx    53    4870    9275.477    24503.391    149881567
ateb    externaldata    membership    membership_pkey    52    21    40.641    110.000    14090226
ateb    obcresult    refillpostingrx    refillpostingrx_pkey    51    2152    4252.258    12084.891    33436460
ateb    obc    phone_lookup_log    phone_lookup_log_phone_number_client_id_idx    51    86    168.078    431.555    0
ateb    patient    patientname7    patient_patientname7_pkey    51    212    418.891    1140.344    9915832
demo_db=# \d+ index_demo
                                                Table "public.index_demo"
 Column |  Type   | Collation | Nullable |                Default                 | Storage  | Stats target | Description
--------+---------+-----------+----------+----------------------------------------+----------+--------------+-------------
 id     | integer |           | not null | nextval('index_demo_id_seq'::regclass) | plain    |              |
 name   | text    |           |          |                                        | extended |              |
Indexes:
    "idx_demo_name_uniq" UNIQUE, btree (name)
    "unique_name" UNIQUE CONSTRAINT, btree (name)
    "idx_demo_name" btree (name)
```

```
:::-->cat duplicate_indexes.txt
-[ RECORD 1 ]-----------------+-------------------------------------------------------------------------------
table                         | public.index_demo
dup index                     | idx_demo_name
dup index definition          | CREATE INDEX idx_demo_name ON public.index_demo USING btree (name)
dup index attributes          | 2
encompassing index            | idx_demo_name_uniq
encompassing index definition | CREATE UNIQUE INDEX idx_demo_name_uniq ON public.index_demo USING btree (name)
enc index attributes          | 2
-[ RECORD 2 ]-----------------+-------------------------------------------------------------------------------
table                         | public.index_demo
dup index                     | idx_demo_name
dup index definition          | CREATE INDEX idx_demo_name ON public.index_demo USING btree (name)
dup index attributes          | 2
encompassing index            | unique_name
encompassing index definition | CREATE UNIQUE INDEX unique_name ON public.index_demo USING btree (name)
enc index attributes          | 2
-[ RECORD 3 ]-----------------+-------------------------------------------------------------------------------
table                         | public.index_demo
dup index                     | idx_demo_name_uniq
dup index definition          | CREATE UNIQUE INDEX idx_demo_name_uniq ON public.index_demo USING btree (name)
dup index attributes          | 2
encompassing index            | unique_name
encompassing index definition | CREATE UNIQUE INDEX unique_name ON public.index_demo USING btree (name)
enc index attributes          | 2
-[ RECORD 4 ]-----------------+-------------------------------------------------------------------------------
table                         | public.index_demo
dup index                     | unique_name
dup index definition          | CREATE UNIQUE INDEX unique_name ON public.index_demo USING btree (name)
dup index attributes          | 2
encompassing index            | idx_demo_name_uniq
encompassing index definition | CREATE UNIQUE INDEX idx_demo_name_uniq ON public.index_demo USING btree (name)
enc index attributes          | 2
```

Note that the UNIQUE CONSTRAINT shows up as its underlying index.  You only need to keep one of these three indexes;  usually that's one of the UNIQUE options.
