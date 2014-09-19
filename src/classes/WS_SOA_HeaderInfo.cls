//Generated by wsdl2apex

public class WS_SOA_HeaderInfo {
    
    //private String[] ns_map_type_info = new String[] {'http://services.vertu.com/schema/common/header/v01/Header','Header'};
    public class Header {
        public String UserName;
        public String Password;
        public String SecurityToken;
        public String Domain;
        public String Role;
        public String MessageID;
        public String TransactionID;
        public DateTime Timestamp;
        
        //private String[] UserName_type_info = new String[]{'UserName','WS_SOA_MaintainCustomerInterface.MaintainCustomerServiceHTTPBinding.GlobalHeaderNS',null,'0','1','false'};
            
        private String[] UserName_type_info = new String[]{'UserName','http://services.vertu.com/schema/common/header/v01/Header',null,'0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://services.vertu.com/schema/common/header/v01/Header',null,'0','1','false'};
        private String[] SecurityToken_type_info = new String[]{'SecurityToken','http://services.vertu.com/schema/common/header/v01/Header',null,'0','1','false'};
        private String[] Domain_type_info = new String[]{'Domain','http://services.vertu.com/schema/common/header/v01/Header',null,'0','1','false'};
        private String[] Role_type_info = new String[]{'Role','http://services.vertu.com/schema/common/header/v01/Header',null,'0','1','false'};
        private String[] MessageID_type_info = new String[]{'MessageID','http://services.vertu.com/schema/common/header/v01/Header',null,'0','1','false'};
        private String[] TransactionID_type_info = new String[]{'TransactionID','http://services.vertu.com/schema/common/header/v01/Header',null,'0','1','false'};
        private String[] Timestamp_type_info = new String[]{'Timestamp','http://services.vertu.com/schema/common/header/v01/Header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.vertu.com/schema/common/header/v01/Header','true','false'};
        private String[] field_order_type_info = new String[]{'UserName','Password','SecurityToken','Domain','Role','MessageID','TransactionID','Timestamp'};
    }
}