/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * ProblemReportInfo テストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2024/3      新規作成     kikuchi
 ********************************************************************************/
@isTest
public with sharing class ProblemReportInfoTest {
    /**
     * getLastchangeCnv
     * 
     */
    @isTest static void testGetLastchangeCnv() {
        ProblemReportInfo problemReportInfo = new ProblemReportInfo();
        problemReportInfo.lastchange = 1710466443;
        String result = problemReportInfo.getLastchangeCnv();
    }

    /**
     * getPriorityCnv
     * 
     */
    @isTest static void testGetPriorityCnv() {
        ProblemReportInfo problemReportInfo = new ProblemReportInfo();
        problemReportInfo.priority = '1';
        String result = problemReportInfo.getPriorityCnv();
    }

    /**
     * getMaintenanceStatusCnv
     * 
     */
    @isTest static void testGetMaintenanceStatusCnv() {
        ProblemReportInfo problemReportInfo = new ProblemReportInfo();
        problemReportInfo.maintenance_status = '1';
        String result = problemReportInfo.getMaintenanceStatusCnv();
    }

    /**
     * getPriorityColorCnv
     * 
     */
    @isTest static void testGetPriorityColorCnv() {
        ProblemReportInfo problemReportInfo = new ProblemReportInfo();
        problemReportInfo.priority = '1';
        String result = problemReportInfo.getPriorityColorCnv();
    }

    /**
     * getDuration
     * 
     */
    @isTest static void testGetDuration() {
        ProblemReportInfo problemReportInfo = new ProblemReportInfo();
        problemReportInfo.lastchange = 1710466443;
        String result = problemReportInfo.getDuration();
    }
}