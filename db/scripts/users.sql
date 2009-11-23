INSERT INTO `users` (`id`, `login`, `remember_token`, `email`, `firstName`, `lastName`, `crypted_password`, `password_reset_code`, `salt`, `activation_code`, `remember_token_expires_at`, `activated_at`, `deleted_at`, `state`, `phone`, `mobile`, `addr1`, `addr2`, `addr3`, `city`, `region`, `postCode`, `userType`, `created_at`, `updated_at`, `contractor_id`, `agency_id`, `title`) VALUES
(1, 'controller', NULL, 'ben.hinton@intura.co.uk', 'Ben', 'Hinton', '04f6620a21c8830cdbe6d936d127ba40cc45025c', 'ba5b514809805a2df2fefe7396b41e309a9317cf', 'b0f65104c8cce6927fef8a4f77bc45cbfb8d58c4', NULL, NULL, '2009-04-12 16:10:38', NULL, 'active', '020 8868 5303', '07764 461 696', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2009-04-12 16:08:11', '2009-04-16 14:56:50', NULL, NULL, 'Mr'),
(2, 'charlesdaly', NULL, 'charles.daly@intura.co.uk', 'Charles', 'Daly', '0c07d43a5066c7c3df4f388bc48134cc29d62e79', 'bf19b01e273a81330b65b9241eafc61522280508', '0cafe5bd87c9e4665968b4fff8e93ccd173e1632', NULL, NULL, '2009-04-14 13:20:37', NULL, 'active', '020 8645 6211', '07465 441 446', '128 West Street', '', '', 'Greenford', 'Middlesex', 'UB1 2GF', 'contractor', '2009-04-14 09:58:48', '2009-04-14 13:22:07', 2, NULL, 'Mr'),
(3, 'alanbraine', NULL, 'alan.braine@intura.co.uk', 'Alan', 'Braine', 'c885d1734726cba0238e03b9e64b95f867fabb5f', 'b021b381696cf7e4b89b2ed7fe4b09c3a1e864f9', '7468a9b4c553ddd29ff4fd1d4477052d900d84fe', NULL, NULL, '2009-06-25 10:22:22', NULL, 'active', '020 8645 7266', '07965 782 112', NULL, NULL, NULL, NULL, NULL, NULL, 'agency', '2009-04-16 13:32:21', '2009-09-08 15:03:11', NULL, 5, 'Mr'),
(4, 'ingridjames', NULL, 'ingrid.james@intura.co.uk', 'Ingrid', 'James', '835e5532b3c20293434c1fa200d5bb1b24b4f6f2', '1bec95895c3480d0f0ff512e6baed8b94dabe92b', '3279df64680425d9cde28a2e530f45bfb929c5e2', NULL, NULL, '2009-04-16 14:23:22', NULL, 'active', '020 8645 7267', '07655 725 112', NULL, NULL, NULL, NULL, NULL, NULL, 'approver', '2009-04-16 13:57:26', '2009-07-08 15:25:25', NULL, NULL, 'Mrs'),
(5, 'edfrank', NULL, 'edward.frank@intura.co.uk', 'Edward', 'Frank', '3fe66eb47e8e414d2ecf166f4e4d1318508fa7ca', '3c8bb414173f7220b2b6d40889096e34fa3d76c4', '6833ea4471f6e97479b83026cfefd8b9a3064e7f', '', NULL, NULL, NULL, 'active', '020 8645 7269', '07655 725 114', NULL, NULL, NULL, NULL, NULL, NULL, 'agency', '2009-04-16 14:35:01', '2009-04-16 14:35:01', NULL, 5, 'Mr'),
(6, 'marknorris', NULL, 'mark.norris@intura.co.uk', 'Mark', 'Norris', '23d7129cba4f6a5ea2d7a928d217a9688c0b0743', '5971f3c4bfe1c9a8d36a18ff2ec5a57514d2fd80', '681d395d77f2d9ee2b36be5d291326926731ebe7', NULL, NULL, '2009-04-16 14:50:28', NULL, 'active', '020 8633 5555', '07755 555 5555', NULL, NULL, NULL, NULL, NULL, NULL, 'approver', '2009-04-16 14:47:51', '2009-05-20 21:47:52', NULL, NULL, 'Mr'),
(7, 'andybriggs', NULL, 'andy.briggs@intura.co.uk', 'Andy', 'Briggs', 'd4f3f9771da4af9ab726e71f1cc43de15a466ab7', '1a0a3e3e8b49b0078eb57e1c60fb334197b50148', '91526186aa9484c7b6fa47f92167aff8e0648fd0', NULL, NULL, '2009-04-16 21:29:04', NULL, 'active', '020 8746 4616', '', '78 Cranford Road', '', '', 'Harrow', 'MIddlesex', 'HA3 7TG', 'contractor', '2009-04-16 21:28:45', '2009-04-16 21:29:04', 7, NULL, 'Mr'),
(8, 'owenpeters', NULL, 'owen.peters@intura.co.uk', 'Owen', 'Peters', 'e4ab81599e803b99d30e9d6426153a67bd2000ab', '98b264c326ab239582186f1b694b5f23581ca8b0', 'acba249dd0c6e92a8aa8d3b5f968c63b94919faa', NULL, NULL, '2009-04-17 07:51:29', NULL, 'active', '', '', NULL, NULL, NULL, NULL, NULL, NULL, 'approver', '2009-04-17 07:47:46', '2009-04-17 07:53:15', NULL, NULL, 'Mr'),
(9, 'terryvance', NULL, 'terry.vance@intura.co.uk', 'Terry', 'Vance', '943f7c202f2bca5be9136d83fc691d029f1a8854', '7d29a81710bfcc6d7357d434aff1e3b0ea115b08', 'c738135db55f2f418470053b05f28193410213e3', NULL, NULL, '2009-04-17 07:56:48', NULL, 'active', '', '07958 411 542', NULL, NULL, NULL, 'Harlow', NULL, NULL, 'contractor', '2009-04-17 07:55:52', '2009-04-17 07:57:34', 9, NULL, 'Mr'),
(10, 'rstevens', NULL, 'rachel.stevens@intura.co.uk', 'Rachel', 'Stevens', '6187cf04c918c93cf12565a8469a82b700803a41', '9e01549dbd7353d42d97b7a416c3d2a5b1f1422f', '4c72b5d1b1af4d7d7d7bf23e0bac6a98a013d83a', NULL, NULL, '2009-04-17 09:55:14', NULL, 'active', '01895 465 665', '', '12 Uxbridge Road', '', '', 'Uxbridge', 'Middlesex', 'UB2 8YS', 'contractor', '2009-04-17 09:54:21', '2009-04-17 09:55:14', 10, NULL, 'Miss'),
(11, 'kevinlay', NULL, 'kevin.lay@intura.co.uk', 'Kevin', 'Lay', '308aeb5b0868a26109da864f237aeacda066f46c', '6398b8107afaf1e292bcf40173c81f32d4b8368a', 'b1769f07fca1a77d4d01a2b265d2dcb03d716ca1', NULL, NULL, '2009-04-17 11:43:30', NULL, 'active', '020 7845 6544', '', NULL, NULL, NULL, NULL, NULL, NULL, 'approver', '2009-04-17 11:42:50', '2009-05-07 19:30:02', NULL, NULL, 'Mr'),
(12, 'jamesbrand', NULL, 'james.brand@intura.co.uk', 'James', 'Brand', '0b4c5f5d26176d0a86d6574b6b3dd55ac692bd49', '05547809c697fd9574455c8e797736bf2991a8f3', '230ef21d9b6fb81aa63073412e337a89db9db18d', NULL, NULL, '2009-07-19 19:42:45', NULL, 'active', '', '', NULL, NULL, NULL, NULL, NULL, NULL, 'agency', '2009-07-19 19:41:05', '2009-09-08 15:02:59', NULL, 5, 'Mr'),
(13, 'grahamhilton', NULL, 'graham.hilton@intura.co.uk', 'Graham', 'Hilton', 'cf70e53a56f584a73dc2503512e38e438628787f', 'b9d3042ea56a1db0336a72f99224d85d052da282', '867641ec8a4c4bd7a7e294073780f713af8793e1', NULL, NULL, '2009-07-19 19:44:33', NULL, 'active', '', '', NULL, NULL, NULL, NULL, NULL, NULL, 'agency', '2009-07-19 19:42:04', '2009-09-08 15:02:45', NULL, 5, 'Mr'),
(14, 'janetsmith', NULL, 'janet.smith@intura.co.uk', 'Janet', 'Smith', 'f13a88d9b854a9d37d2c337c3035f9e58ae9e7b2', '13ead71f74e54e092fd96ab444952766ce8f74a9', '92697973656cfef19cd1db9d9758a11be205641c', NULL, NULL, '2009-07-19 20:10:48', NULL, 'active', '', '07455 654 454', '60 Highgrove Road', '', '', 'Ruislip', 'Middlesex', 'HA6 7BD', 'contractor', '2009-07-19 20:08:28', '2009-07-19 20:10:48', 14, NULL, 'Miss'),
(15, 'paulsmith', NULL, 'paul.smith@intura.co.uk', 'Paul', 'Smith', '52db363a6298c2379684ef922cb0c1b4344f4211', '9b0994abd1193d6dc30af9d5fa77cfce170d96b9', 'b5cb3066a988566147e32416d0751b986a701b74', NULL, NULL, '2009-07-19 20:13:12', NULL, 'active', '', '07895 544 144', '101 Joel Street', '', '', 'Pinner', 'Middlesex', 'HA5 9DA', 'contractor', '2009-07-19 20:12:48', '2009-07-19 20:13:12', 15, NULL, 'Mr'),
(16, 'marysmith', NULL, 'mary.smith@intura.co.uk', 'Mary', 'Smith', 'd1ad66606704d13ba08c95c322fcd7148c4bec0e', '80500b089b78c4f5fa4396cec66d9795738f2966', 'f0576669d3c21c95f96c5e538b6e806d95482b0c', NULL, NULL, '2009-07-19 20:15:08', NULL, 'active', '', '07545 658 100', '15 Ivy Close', '', '', 'Slough', 'Berks', 'SL1 2YD', 'contractor', '2009-07-19 20:14:49', '2009-07-19 20:15:08', 16, NULL, 'Mrs'),
(17, 'angelasmith', NULL, 'angela.smith@intura.co.uk', 'Angela', 'Smith', '3d759f1e9fb8cdb87d0b004a8a91e74d918113cd', '72b8bdb1be5bc08b4c2008f4e8f0d731a0217299', 'ced820ff3382e9507d542a455d0f64fc596b3f7c', NULL, NULL, '2009-07-19 20:23:15', NULL, 'active', '', '07765 462 132', '75 Church Avenue', '', '', 'Denham', 'Berks', 'SL2 7RH', 'contractor', '2009-07-19 20:22:44', '2009-07-19 20:23:15', 17, NULL, 'Mrs'),
(18, 'debbiesmith', NULL, 'debbie.smith@intura.co.uk', 'Debbie', 'Smith', '52d51d1c68c3a0477e8228b32207193c0d111aa1', '50ba7b02c41f84ae352595494ad23f6462ee373a', '5cfe6c926ef321716a4777162289f8862cf7559e', NULL, NULL, '2009-07-19 20:25:24', NULL, 'active', '', '07774 130 200', '100 Whittington Way', '', '', 'Pinner', 'Middlesex', 'HA5 5TY', 'contractor', '2009-07-19 20:24:56', '2009-07-19 20:25:24', 18, NULL, 'Miss'),
(19, 'dianesmith', NULL, 'diane.smith@intura.co.uk', 'Diane', 'Smith', '8ab2d00326bceb37cab6c0ca5b6edeab8db478a5', '5436f718489d80c4ab69b0abc65ec3d94bd19938', 'cb5f5b73f89f16649888740508dae84235b1b5bc', NULL, NULL, '2009-07-19 20:27:34', NULL, 'active', '', '07322 977 463', '25 Eastcote Road', '', '', 'Windsor', 'Berks', 'SL3 7RH', 'contractor', '2009-07-19 20:27:07', '2009-07-19 20:27:34', 19, NULL, 'Miss'),
(20, 'jimmybun', NULL, 'jimmy@hotmail.com', 'Jimmy', 'Bun', 'bced81b0b4807c41f2bee3987746579f5d788f15', '64d5f0a100ef78ca753c4b8513ec9ea8601dd58d', '410d740cc4d318acfff7cff694b0f56db0770e70', '6fe0f88b49dff9d4719423a7b74388eabc202d2e', NULL, NULL, NULL, 'pending', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'agency', '2009-07-20 08:52:10', '2009-07-20 08:52:10', NULL, 7, 'Mr'),
(21, 'carladale', NULL, 'carla.dale@intura.co.uk', 'Carla', 'Dale', '538500143ad769a76334f4a1b512a0129250ad74', '3a5d90928ffa0a876c3dae1c4baf66d6ad0e2ddb', 'a742106f8aba871d1733aa63213d264d5e0df5cc', NULL, NULL, '2009-09-09 08:22:46', NULL, 'active', '', '', '15 Carnaby Street', '', '', 'London', '', 'W1', 'contractor', '2009-09-09 08:22:25', '2009-09-09 08:22:46', 21, NULL, 'Miss'),
(22, 'willarkel', NULL, 'william.arkel@intura.co.uk', 'William', 'Arkel', '084671b53c4130ddb8a31f64ff0647641433879b', 'aebe4492eec2925e6facef3467f4238fdaa5c772', '1c2d16167e856580c3ab50e3c28cb0fb9ebc18fe', NULL, NULL, '2009-09-09 08:28:37', NULL, 'active', '020 7416 6522', '', NULL, NULL, NULL, NULL, NULL, NULL, 'approver', '2009-09-09 08:25:44', '2009-09-09 08:28:37', NULL, NULL, 'Mr'),
(23, 'jmunro', NULL, 'info@clockoff.com', 'Jim', 'Munro', '85ab0b2fd5acad3b6b9303d16ecf0a74e6afbf31', '26b15c8f50ac39756760b071273489fdc72d3442', 'cdc90b78348049250fd892f99fe27daff07b6ca9', NULL, NULL, '2009-09-25 20:18:42', NULL, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'agency', '2009-09-25 20:18:10', '2009-09-25 20:18:43', NULL, 10, 'Mr');
