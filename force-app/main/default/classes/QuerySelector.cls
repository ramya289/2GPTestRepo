public abstract with sharing class QuerySelector {

    /**
     * Enforce FLS Security
     **/
    private Boolean l_enforceFLS = true;

    /**
     * Enforce READ object Security
     **/
    private Boolean l_enforceRead = true;

    /**
     * If field fails FLS security
     *  - true - will throw the error
     *  - false - will remove the field from the query.
     *
     **/
    private Boolean l_throwFLSException = true;


    public QuerySelector() {
        this(true, true);
    }

    public QuerySelector(Boolean enforceRead, Boolean enforceFLS) {
        this(enforceRead,enforceFLS,true);
    }

    public QuerySelector(Boolean enforceRead, Boolean enforceFLS, Boolean throwFLS) {
        l_enforceRead = enforceRead;
        l_enforceFLS = enforceFLS;
        l_throwFLSException = throwFLS;
    }

    public abstract Schema.SObjectType getSObjectType();

    public abstract List<Schema.SObjectField> getSObjectFieldList();

    public abstract String getOrderBy();

    public QueryBuilder newQueryBuilder(){
        QueryBuilder qb = new QueryBuilder(getSObjectType(), l_enforceRead, l_enforceFLS, l_throwFLSException);
        qb.addSObjectFields(getSObjectFieldList());
        return qb;
    }

    public QueryBuilder newQueryBuilderWithRelatedFields(List<String> relatedFields){
        QueryBuilder qb = newQueryBuilder();
        if(relatedFields != null) {
            qb.addRelatedFields(relatedFields);
        }
        return qb;
    }

}