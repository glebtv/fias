module Fias
  module Import
    module DownloadService
      def data
        response = HTTParty.get(
          'https://fias.nalog.ru/WebServices/Public/GetAllDownloadFileInfo',
        )
        data = JSON.parse(response.body)
        data = data.reject {|d| d["FiasCompleteDbfUrl"].blank? }.sort_by { |d| d["VersionId"] }.reverse
        data[0]
      end
      def url
        data["FiasCompleteDbfUrl"]
      end
      module_function :data
      module_function :url
    end
  end
end
