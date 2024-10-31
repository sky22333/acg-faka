<?php
declare(strict_types=1);
namespace App\Pay\Tokenpay\Impl;

use Kernel\Util\Context;

class Signature implements \App\Pay\Signature
{
   /**
    * 生成签名
    * @param array $data
    * @param string $key
    * @return string
    */
   public static function generateSignature(array $parameter, string $signKey): string
   {
       unset($parameter['Signature']);
       
       ksort($parameter);
       
       $sign = '';
       foreach ($parameter as $key => $val) {
           if ($val === '') continue;
           if ($sign !== '') {
               $sign .= '&';
           }
           $sign .= "$key=$val";
       }
       
       return md5($sign . $signKey);
   }

   /**
    * @inheritDoc
    */
   public function verification(array $data, array $config): bool
   {
       // 获取原始POST数据
       $rawData = json_decode(file_get_contents('php://input'), true);
       if (!$rawData) {
           $rawData = $data;
       }
       
       if (!isset($rawData['Signature'])) {
           return false;
       }
       
       $sign = $rawData['Signature'];
       $generateSignature = self::generateSignature($rawData, $config['key']);
       
       if ($sign !== $generateSignature) {
           return false;
       }
       
       Context::set(\App\Consts\Pay::DAFA, $rawData);
       return true;
   }
}
