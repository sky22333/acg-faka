<?php
declare (strict_types=1);

return [
    'version' => '1.0.0',
    'name' => 'Tokenpay',
    'author' => '',
    'website' => 'https://github.com/LightCountry/TokenPay',
    'description' => 'Tokenpay',
    'options' => [
        'TRX' => 'TRX',
        'USDT_TRC20' => 'USDT-TRC20',
        'EVM_BSC_BNB' => 'BNB',
        'EVM_BSC_USDT_BEP20' => 'USDT-BEP20',
        'EVM_Polygon_MATIC' => 'MATIC',
        'EVM_Polygon_USDT_ERC20' => 'USDT-POLYGON',
        'EVM_ETH_ETH' => 'ETH',
        'EVM_ETH_USDT_ERC20' => 'USDT-ERC20',
    ],
    'callback' => [
        \App\Consts\Pay::IS_SIGN => true,
        \App\Consts\Pay::IS_STATUS => true,
        \App\Consts\Pay::FIELD_STATUS_KEY => 'Status',
        \App\Consts\Pay::FIELD_STATUS_VALUE => 1,
        \App\Consts\Pay::FIELD_ORDER_KEY => 'OutOrderId',
        \App\Consts\Pay::FIELD_AMOUNT_KEY => 'ActualAmount',
        \App\Consts\Pay::FIELD_RESPONSE => 'ok'
    ]
];