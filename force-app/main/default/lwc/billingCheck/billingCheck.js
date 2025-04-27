import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import ISINVOICESENDING_FIELD from '@salesforce/schema/BillingHeader__c.IsInvoiceSending__c';
import ISDEPOSITED_FIELD from '@salesforce/schema/BillingHeader__c.IsDeposited__c';
import ID_FIELD from '@salesforce/schema/BillingHeader__c.Id';
import billingCheckUpdate from '@salesforce/apex/BillingHeaderController.billingCheckUpdate';
import { refreshApex } from '@salesforce/apex';

export default class BillingCheck extends LightningElement {

    @api recordId;
    @track error;

    // レコード詳細の取得
    @wire(getRecord,{recordId: '$recordId',fields: [ISINVOICESENDING_FIELD,ISDEPOSITED_FIELD]})
    billing;

    updateBilling() {

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ISINVOICESENDING_FIELD.fieldApiName] = this.template.querySelector("[data-field='IsInvoiceSending__c']").checked;
        fields[ISDEPOSITED_FIELD.fieldApiName] = this.template.querySelector("[data-field='IsDeposited__c']").checked;
        const recordInput = { fields };

        // Apex呼び出しでチェックボックスの更新を行う（レコードロック対策）
        billingCheckUpdate({billing:fields})
            .then(() => {
                // 請求詳細の更新を行う
                refreshApex(this.billing)
                        .then(() => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: '完了',
                                    message: '請求の更新が完了しました。',
                                    variant: 'success'
                                })
                            );
                        });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '更新エラー',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}