<?php
declare(strict_types=1);

namespace App\Pay\Tokenpay\Impl;

use App\Entity\PayEntity;
use App\Pay\Base;
// use App\Util\PayConfig;
use GuzzleHttp\Exception\GuzzleException;
use Kernel\Exception\JSONException;

/**
 * Class Pay
 * @package App\Pay\Kvmpay\Impl
 */
class Pay extends Base implements \App\Pay\Pay
{

    /**
     * @return PayEntity
     * @throws JSONException
     */
    public function trade(): PayEntity
    {
        if (!$this->config['url']) {
            throw new JSONException("请配置网关地址");
        }
        if (!$this->config['key']) {
            throw new JSONException("请配置密钥");
        }
        $param = [
            'OutOrderId' => $this->tradeNo,
            'OrderUserKey' => $this->tradeNo,
            'ActualAmount' => $this->amount,
            'Currency' => $this->code,
            'NotifyUrl' => $this->callbackUrl,
            'RedirectUrl' => $this->returnUrl
        ];
        $param['Signature'] = Signature::generateSignature($param, $this->config['key']);

        // PayConfig::log($this->handle, "PARAM", json_encode($param));

        try {
            $request = $this->http()->post(trim($this->config['url'], "/") . '/CreateOrder', [
                "json" => $param
            ]);
        } catch (GuzzleException $e) {
            throw new JSONException("网关连接失败，下单未成功");
        }
        $contents = $request->getBody()->getContents();

        // PayConfig::log($this->handle, "RESPONSE", $contents);

        $arr = (array)json_decode((string)$contents, true);
        if ($arr['success'] == false) {
            throw new JSONException((string)$arr['message']);
        }

        $payEntity = new PayEntity();
        $payEntity->setType(self::TYPE_REDIRECT);
        $payEntity->setUrl($arr['data']);
        return $payEntity;
    }
}