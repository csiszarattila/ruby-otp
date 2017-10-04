require 'savon'

module OTP

  class Message
    attr_accessor :fields
    attr_accessor :templateName

    def initialize()
        @fields = Hash.new
    end

    def to_s
      '<?xml version="1.0" encoding="UTF-8"?>' +
      Gyoku.xml(
        "StartWorkflow" => {
          "TemplateName" => templateName,
          "Variables" => fields
        }
      )
    end
  end

  class TransactionIdRequestMessage < Message
    def initialize
      super
      @templateName = "WEBSHOPTRANZAZONGENERALAS"
    end
  end

  class PayingService
    def initialize(posId, pathToSignKey)
      @posId = posId
      @client = Savon.client(
        wsdl: "https://www.otpbankdirekt.hu/mwaccesspublic/mwaccess?wsdl",
        log: true
      )
      @signKey = OpenSSL::PKey::RSA.new File.read pathToSignKey
    end

    def sendMessage(message)
      message.fields["isPOSID"] = @posId
      message.fields["isClientCode"] = "WEBSHOP"
      message.fields["isClientSignature"] = self.signMessage(message)

p message.to_s

      p @client.call(:start_workflow_synch, message: {
        "arg0" => message.templateName,
        "arg1" => message.to_s
      })
    end

    def signMessage(message)
      signatureFields = ["isPOSID"]
      if (message.kind_of? TransactionIdRequestMessage)
      end

      dataToSign = message.fields.values_at(*signatureFields).join("|")
      digest = @signKey.sign(OpenSSL::Digest::SHA512.new, dataToSign)
      digest.unpack("H*")
    end

    def requestTransactionId()
      sendMessage(TransactionIdRequestMessage.new)
    end
  end
end

p = OTP::PayingService.new("#02299991", "#02299991.privKey.pem")
p.requestTransactionId()
