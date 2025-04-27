/********************************************************************************
 *
 * 連絡先情報編集画面コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/06          
 ********************************************************************************
 * 2022/07/13 監査履歴（メールでのご連絡先）対応          
 ********************************************************************************/
public without sharing class NotifyInfoEditController {

    //エラーメッセージ
    public static final String ERR_NO_CONSTITUTION = '案件情報が設定されていません';

    // 連絡先情報
    public NotifyInfo__c notifyinfo { get; set; }
    public NotifyInfo__c beforeNotifyInfo {get;set;}
    //曜日のチェックボックスの値を保存する変数を定義する
    public Map<String,boolean> daymap{get;set;}

    /* 案件情報 */
    public Constitution_Common__c constitutionInfo {get;set;}
    public String constitutionName {get;set;}
    public String companyName {get;set;}

    /* 営業時間内の連絡先順番 */
    public String on_display_order1{get;set;}
    public String on_display_order2{get;set;}
    public String on_display_order3{get;set;}

    /* 営業時間外の連絡先順番 */
    public String off_display_order1{get;set;}
    public String off_display_order2{get;set;}
    public String off_display_order3{get;set;}
    
    /* オペレータフラグ */
    public boolean operatorFlg{get;set;}

    /* 画面表示判断用のその他連絡先の名前保存配列 */
    public List<String> originalOtherNameList{get;set;}

    /* 画面表示判断用のその他連絡先の名前保存配列 */
    public List<String> originalEmailList{get;set;}

    public NotifyInfoEditController(ApexPages.StandardController stdController) {
        this.notifyinfo = (NotifyInfo__c) stdController.getRecord();
        // if(this.notifyinfo.Id!=null)this.beforeNotifyInfo = this.notifyinfo.clone(false,true,true,true);
        this.operatorFlg = true;
        daymap = new Map<String,boolean>{
            '月' => false, 
            '火' => false, 
            '水' => false, 
            '木' => false, 
            '金' => false, 
            '土' => false, 
            '日' => false,
            '祝' => false
        };
        originalOtherNameList = new List<String>(20);
        originalEmailList = new List<String>(20);
        for(Integer loopnum=0; loopnum < 20; loopnum++){
            originalOtherNameList[loopnum] = '';
            originalEmailList[loopnum] = '';
        }
    }

    /**
     * 初期処理
     */
    public void initAction() {
        try{
            /* 連絡先情報 */
            String nid = this.notifyinfo.Id;
            if(String.isNotBlank(nid)){
                List<Schema.FieldSetMember> fields = SObjectType.NotifyInfo__c.FieldSets.ChangeInputSetForOperator.getFields();
                String query = 'SELECT ';
                for(Schema.FieldSetMember f : fields) {
                    query += f.getFieldPath() + ', ';
                }
                query += 'Name FROM NotifyInfo__c WHERE Id=:nid';

                List<NotifyInfo__c> nlist = Database.query(query);
                this.notifyInfo = nlist.get(0);

                for(Integer loopnum=0; loopnum < 20; loopnum++){
                    Integer plusOneNum = loopnum + 1;
                    String orgname = (String)notifyInfo.get('Etc' + plusOneNum + '_Name__c');
                    String orgemail = (String)notifyInfo.get('Etc' + plusOneNum + '_Mail__c');
                    if(String.isNotBlank(orgname)) originalOtherNameList[loopnum] = orgname;
                    if(String.isNotBlank(orgemail)) originalEmailList[loopnum] = orgemail;
                }

                // this.beforeNotifyInfo = this.notifyinfo.clone(false,true,false,false);   //2023.07.13 comment out
                this.beforeNotifyInfo = this.notifyinfo.clone(false,true,true,false);       //2023.07.13 add
                this.beforeNotifyInfo.HenshuUser__c = this.beforeNotifyInfo.LastModifiedById; //2023.07.13 add
                this.beforeNotifyInfo.HenshuDateTime__c = this.beforeNotifyInfo.LastModifiedDate; //2023.07.13 add

                /* 案件情報 */
                List<Constitution_Common__c> cclist = [
                    SELECT
                        ID
                        ,Name
                        ,ChargeOption__c
                        ,Account__r.name
                    FROM Constitution_Common__c
                    WHERE ID = :notifyinfo.ConstitutionCommon__c
                ];

                if(cclist.size()>0){
                    constitutionInfo = cclist.get(0);
                    constitutionName = constitutionInfo.Name;
                    companyName = cclist.get(0).Account__r.name;
                }

            }else{
                //新規作成時
                Id constitutionCommonId = this.notifyinfo.ConstitutionCommon__c;
                this.notifyInfo = new NotifyInfo__c();
                this.notifyInfo.ConstitutionCommon__c = constitutionCommonId;
                for(Integer loopnum=1; loopnum < 21; loopnum++){
                    notifyInfo.put('Etc'+loopnum+'_AlertContact__c',false);
                    notifyInfo.put('Etc'+loopnum+'_OtherThanAlertContact__c',false);
                    notifyInfo.put('Etc'+loopnum+'_MonthlyReportSender__c',false);
                    notifyInfo.put('Etc'+loopnum+'_Del__c',false);
                }
                this.beforeNotifyInfo = this.notifyinfo.clone(false,true,true,true);
            }
            //曜日のチェックボックスの値を保存する変数に値をセットする
            if(String.isNotBlank(this.notifyinfo.Week__c)){
                if(this.notifyinfo.Week__c.contains('月')) daymap.put('月',true);
                if(this.notifyinfo.Week__c.contains('火')) daymap.put('火',true);
                if(this.notifyinfo.Week__c.contains('水')) daymap.put('水',true);
                if(this.notifyinfo.Week__c.contains('木')) daymap.put('木',true);
                if(this.notifyinfo.Week__c.contains('金')) daymap.put('金',true);
                if(this.notifyinfo.Week__c.contains('土')) daymap.put('土',true);
                if(this.notifyinfo.Week__c.contains('日')) daymap.put('日',true);
                if(this.notifyinfo.Week__c.contains('祝')) daymap.put('祝',true);
            }
        }catch(Exception e){
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getLineNumber() +' '+e.getMessage()));
        }

    }

    public Pagereference save(){
        try{
            String eigyoYoubi='';

            if(daymap.get('日')) eigyoYoubi = '日';
            if(daymap.get('月')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '月';
                else eigyoYoubi = eigyoYoubi + ';' + '月';
            }
            if(daymap.get('火')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '火';
                else eigyoYoubi = eigyoYoubi + ';' + '火';
            }
            if(daymap.get('水')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '水';
                else eigyoYoubi = eigyoYoubi + ';' + '水';
            }
            if(daymap.get('木')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '木';
                else eigyoYoubi = eigyoYoubi + ';' + '木';
            }
            if(daymap.get('金')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '金';
                else eigyoYoubi = eigyoYoubi + ';' + '金';
            }
            if(daymap.get('土')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '土';
                else eigyoYoubi = eigyoYoubi + ';' + '土';
            }
            if(daymap.get('祝')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '祝';
                else eigyoYoubi = eigyoYoubi + ';' + '祝';
            }
            notifyinfo.Week__c = eigyoYoubi;

            //インサート前チェック
            if(notifyinfo.ConstitutionCommon__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_NO_CONSTITUTION));
                return null;
            }
            List<Constitution_Common__c> cclist = [
                    SELECT
                        ID
                        ,Name
                        ,ChargeOption__c
                        ,Account__r.name
                    FROM Constitution_Common__c
                    WHERE ID = :notifyinfo.ConstitutionCommon__c
                ];

            if(cclist.size()>0){
                constitutionInfo = cclist.get(0);
            }
            boolean checkflg = CoodleUtil.checkInputContents(true,constitutionInfo.ChargeOption__c,notifyinfo,null);
            if(!checkflg){
                //時間内・時間外の連絡先の順番変更する
                jikangaiReinput();

                //時間内・時間外の削除処理を行う
                deleteTelRenrakusaki();

                //時間内・時間外の空行を詰める
                notifyinfo = CoodleUtil.moveUpTelRenrakusaki(notifyinfo);

                //追加・変更・削除の状況を確認する
                boolean diffFlg = CoodleUtil.chkDiffMailRenrakusaki(notifyinfo,beforeNotifyInfo);

                //削除と変更のチェックを行う
                boolean delchgChlFlg = CoodleUtil.checkDeleteChg(constitutionInfo.ChargeOption__c,notifyinfo);
                if(delchgChlFlg) return null;

                if(diffFlg){
                    //古い履歴があればそれを残す
                    if(this.notifyinfo.PastOne__c==null){
                    
                        //古い連絡先情報をまずはInsertする
                        beforeNotifyInfo.PastOneFLG__c = true;
                        beforeNotifyInfo.PastOne__c = null;
                        System.debug('**==**== insert前 beforeNotifyInfo =>' + beforeNotifyInfo);
                        insert beforeNotifyInfo;

                        //現在の連絡先情報を更新する
                        notifyinfo.PastOne__c = beforeNotifyInfo.id;
                    }
                }
                this.notifyinfo.ShagaiHenshusha__c = null;  //2023.07.28 add
                //現在の連絡先情報を更新する
                upsert this.notifyinfo;
            }else{
                return null;
            }
            
        }catch(Exception e){
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getLineNumber() +' '+e.getMessage()));
            return null;
        }
        String routing = '/apex/NotifyInfoView?id=' + this.notifyinfo.Id;
        PageReference newView = new PageReference(routing);
        newView.setRedirect(true);
        return newView;
    }

    public Pagereference edit() {
        String routing = '/apex/NotifyInfoEdit?id=' + this.notifyinfo.Id;
        PageReference newView = new PageReference(routing);
        newView.setRedirect(true);
        return newView;
    }

    public Pagereference cancel() {
        String routing;
        if (String.isBlank(this.notifyinfo.Id)) {
            routing = '/' + this.notifyinfo.ConstitutionCommon__c;
        } else {
            routing = '/apex/NotifyInfoView?id=' + this.notifyinfo.Id;
        }
        PageReference newView = new PageReference(routing);
        newView.setRedirect(true);
        return newView;
    }

    public Pagereference del() {
        List<NotifyInfo__c> notifylist = [SELECT ID,ConstitutionCommon__c FROM NotifyInfo__c WHERE ID = :this.notifyinfo.Id];
        Id constitutionCommonId = notifylist.get(0).ConstitutionCommon__c;
        delete this.notifyInfo;
        PageReference pr = new PageReference('/' + constitutionCommonId);
        pr.setRedirect(true);
        return pr;
    }

    public Pagereference executeOfficeZendeskAPI(){
        String routing = '/apex/NotifyInfoView?id=' + this.notifyinfo.Id;
        try{
            OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);
            System.enqueueJob(queueable);
            this.notifyinfo.Status__c = '受付';
            this.notifyinfo.ShagaiHenshusha__c = null;  //2023.07.13 add
            update notifyinfo;
        }catch (Exception e) {
            routing = null;
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getLineNumber() +' '+e.getMessage()));
        }

        PageReference newView = new PageReference(routing);
        newView.setRedirect(true);
        return newView;
    }
    public Pagereference executeeZendeskAPI(){
        String routing = '/apex/NotifyInfoView?id=' + this.notifyinfo.Id;
        try{
            ZendeskAPIQueueable queueable = new ZendeskAPIQueueable(notifyInfo.Id, 1);
            System.enqueueJob(queueable);
            this.notifyinfo.Status__c = '受付';
            this.notifyinfo.ShagaiHenshusha__c = null;  //2023.07.13 add
            update notifyinfo;
        }catch (Exception e) {
            routing = null;
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getLineNumber() +' '+e.getMessage()));
        }

        PageReference newView = new PageReference(routing);
        newView.setRedirect(true);
        return newView;
    }
    private void jikangaiReinput(){
        on_display_order1 = ApexPages.CurrentPage().getParameters().get('on_display_order1');
        on_display_order2 = ApexPages.CurrentPage().getParameters().get('on_display_order2');
        on_display_order3 = ApexPages.CurrentPage().getParameters().get('on_display_order3');

        off_display_order1 = ApexPages.CurrentPage().getParameters().get('off_display_order1');
        off_display_order2 = ApexPages.CurrentPage().getParameters().get('off_display_order2');
        off_display_order3 = ApexPages.CurrentPage().getParameters().get('off_display_order3');

        notifyinfo = CoodleUtil.jikangaiReinput(on_display_order1,on_display_order2,on_display_order3,off_display_order1,off_display_order2,off_display_order3,notifyinfo);
    }
    private void deleteTelRenrakusaki(){

        notifyInfo =  CoodleUtil.deleteTelRenrakusaki(notifyInfo);
    }

}