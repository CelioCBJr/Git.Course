                    select
					   	billingaccountid,
						recipientsname,
						roomnumber,
						numreserva,
						nomeconta,
						type,
						number,
						serie,
						rps,
						emissiondate,
						canceldate,
						status,
						deposito,
						cartao,
						faturar,
						cheque,
						dinheiro,
						outrosreceb,
						COALESCE(discamount,0) as desconto,
						0 as restaurante,
						outros,
						0 as bares,
						diaria,
						eventos,
						0 as banquetes,
						lavandeira,
						telecomunicacoes,
						iss,
						taxadeservico,
						(COALESCE(total,0) + COALESCE(discamount,0)) as total,
						servico,
						taxa,
						COALESCE(totalamount,0) + COALESCE(discamount,0) - COALESCE (postotalamount*-1,0) as tipopagamento,
						0 as pontodevenda,
						statusid,
						billinginvoicetypeid,
						symbol,
						aditionaldetails,
						integratorlink,
						integratorxml,
						errordate,
						billinginvoiceid,
						internalcomments,
						externalcomments,
						partnercomments,
                        totalamount,
                        postotalamount
					from
					(
						with nota as 
						(
						select
                            ba.billingaccountid,
							case ba.billingaccounttypeid 
                            	when 1
                            	then COALESCE(header.fullname, cia.tradename) 
                            	when 2
                            	then COALESCE(header.fullname, gri.guestname) 
                            	when 3 
                            	then COALESCE(header.fullname, cia.tradename) 
                            	when 4 
                            	then COALESCE(header.fullname,cia.tradename,gri.guestname) 
                            end as recipientsname,
                            uh.roomnumber,
                            COALESCE(rf.reservationitemcode, '') as numreserva,
                            COALESCE(ba.billingaccountname, 'GERAL') as nomeconta,
							case when bi.externalnumber is not null then bm.description else 'RPS' end as type,
                            COALESCE (bi.externalnumber,bi.billinginvoicenumber) as number,
                            COALESCE (bi.externalseries,bi.billinginvoiceseries) as serie,
                            COALESCE (bi.externalrps,bi.billinginvoicenumber) as rps,
                            COALESCE (bi.externalemissiondate,bi.emissiondate) as emissiondate,
                            cast(bi.canceldate as date),
							case bi.billinginvoicestatusid 
                            	when 9
                            	then 'Nao Enviada' 
                            	when 10
                            	then 'Emitida' 
                            	when 11
                            	then 'Pendente' 
                            	when 12
                            	then 'Erro' 
                            	when 13
                            	then 'Cancelando' 
                           		when 14
                           		then 'Cancelada' 
                            end as status,
							sum(
							case 
								when gf.billingitemcategoryid = 1 and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = 1 
								then lf.amount 
								else 0 
							end) as restaurante,
							sum(
							case 
								when gf.billingitemcategoryid = 2 and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = 2
								then lf.amount 
								else 0 
							end) as outros,
							sum(
							case 
								when gf.billingitemcategoryid = 3 and st.statusid = 14 
								then 0
                                when gf.billingitemcategoryid = 3 
								then lf.amount 
                                else 0 
							end) as bares,
							sum(
							case 
								when gf.billingitemcategoryid = 4 and st.statusid = 14 
								then 0
                                when gf.billingitemcategoryid = 4
								then lf.amount 
                                else 0
							end) as diaria,
							sum(
							case 
								when gf.billingitemcategoryid = 5 and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = 5
								then lf.amount 
								else 0 
							end) as eventos,
							sum(
							case 
								when gf.billingitemcategoryid = 6 and st.statusid = 14 
								then 0
                                when gf.billingitemcategoryid = 6 
								then lf.amount
								else 0 
							end) as banquetes,
							sum(
							case 
								when gf.billingitemcategoryid = 7 and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = 7 
								then lf.amount 
								else 0 
							end) as lavandeira,
							sum(
							case 
								when gf.billingitemcategoryid = 8 and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = 8 
								then lf.amount 
								else 0 
								end) as telecomunicacoes,
							sum(
							case 
								when gf.billingitemcategoryid = 9 and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = 9 
								then lf.amount 
								else 0 end
                                        ) as iss,
							sum(
							case 
								when gf.billingitemcategoryid = 10 and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = 10 
								then lf.amount 
								else 0 
								end) as taxadeservico,
							sum(
							case 
								when tl.billingitemtypeid = 1 and st.statusid = 14 
								then 0
								when tl.billingitemtypeid = 1
								then lf.amount 
								else 0 
								end) as servico,
							sum(
							case 
								when gf.billingitemcategoryid in (9,10) and st.statusid = 14 then 0
								when gf.billingitemcategoryid in (9,10) 
								then lf.amount 
								else 0 
							end) as taxa,
							sum(
							case 
								when tl.billingitemtypeid = 4 and st.statusid = 14 
								then 0
								when tl.billingitemtypeid = 4
								then lf.amount 
								else 0 
							end) as pontodevenda,
							sum(
							case 
								when tl.billingitemtypeid in (1,2) and st.statusid = 14 
								then 0 
								when tl.billingitemtypeid in (1,2) 
								then lf.amount*-1 
								else 0 
							end) as total,
							st.statusid,
							bi.billinginvoicetypeid,
							max(symbol) as symbol,
							bi.aditionaldetails,
							bi.integratorlink,
							bi.integratorxml,
							bi.errordate,
							bi.billinginvoiceid,
							rr.internalcomments,
							rr.externalcomments,
							rr.partnercomments
						FROM property as pr
                        join billingaccount as ba
                        	on pr.tenantid::uuid = ba.tenantid::uuid
                        join billinginvoice as bi 
                        	on pr.tenantid::uuid = bi.tenantid::uuid
                            and bi.billingaccountid = ba.billingaccountid
                        join billinginvoiceproperty as bp 
                        	on bi.tenantid::uuid = bp.tenantid::uuid
                        	and bi.billinginvoicepropertyid = bp.billinginvoicepropertyid
                        	AND bp.isintegrated = TRUE
                        	AND bp.isactive = TRUE
                        	AND bp.isdeleted =FALSE
                        join billinginvoicepropertysupportedtype bs
                        	on bp.tenantid::uuid= bs.tenantid::uuid
							and bp.billinginvoicepropertyid = bs.billinginvoicepropertyid
							and bs.isdeleted = FALSE
                        join billinginvoicemodel as bm 
                        	on bp.billinginvoicemodelid = bm.billinginvoicemodelid 
                        left join billingaccountitem as lf 
                            on bi.billingaccountid = lf.billingaccountid 
                            and bi.billinginvoiceid = lf.billinginvoiceid
                            and bs.billingitemid = lf.billingitemid
                            and lf.isdeleted = false
                        left join billingitem as td 
                            on lf.tenantid::uuid=td.tenantid::uuid
                            and lf.billingitemid=td.billingitemid 
                        join status as st 
                        	on st.statusid = bi.billinginvoicestatusid
                        left join billingitemcategory as gr 
                        	on td.billingitemcategoryid = gr.billingitemcategoryid
                        left join billingitemcategory as gf 
                        	on gr.standardcategoryid = gf.billingitemcategoryid
                        left join billingitemtype as tl 
                        	on td.billingitemtypeid = tl.billingitemtypeid
                        left join reservationitem as rf 
                        	on ba.reservationitemid = rf.reservationitemid
                        left join person as header 
                        	on header.personid = bi.personheaderid
                        left join guestreservationitem as gri 
                        	on ba.guestreservationitemid = gri.guestreservationitemid
                        left join companyclient as cia 
                        	on cia.companyclientid = ba.companyclientid
                        left join reservation as rr 
                        	on rf.reservationid = rr.reservationid
                        left join companyclient as cc 
                        	on rr.companyclientid = cc.companyclientid
                        left join room as uh 
							on rf.roomid = uh.roomid
						left join currency as c 
							on lf.currencyid = c.currencyid
						where pr.tenantid = '2cecdbc0-7de2-45a9-9a19-edcaec7268c3'
						and coalesce(bi.externalemissiondate::date,bi.emissiondate::date)='2023-10-04'
						group by
							ba.billingaccountid,
							bi.externalrps,
							pr.propertyid,
							uh.roomnumber,
							COALESCE(rf.reservationitemcode, ''),
							COALESCE(ba.billingaccountname, 'GERAL'),
							ba.billingaccounttypeid,
							bi.billinginvoicenumber,
							COALESCE(bi.externalemissiondate,bi.emissiondate),
							bi.canceldate,
							bi.billinginvoicestatusid,
							bm.description,
							bi.externalnumber,
							bi.externalseries,
							st.statusid,
							bi.billinginvoicetypeid,
							bi.externalemissiondate,
							bi.aditionaldetails,
							bi.integratorlink,
							bi.integratorxml,
							bi.errordate,
							bi.billinginvoiceid,
							rr.internalcomments,
							rr.externalcomments,
							rr.partnercomments,
							case ba.billingaccounttypeid when 1 then COALESCE(header.fullname, cia.tradename) when 2 then COALESCE(header.fullname, gri.guestname) when 3 then COALESCE(header.fullname, cia.tradename) when 4 then COALESCE(header.fullname, cia.tradename, gri.guestname) end
						)
						, pay as 
                        (
						select 
							billingaccountidpay,
							sum(deposito) as deposito,
							sum(cartao) as cartao,
							sum(faturar) as faturar,
							sum(cheque) as cheque,
							sum(dinheiro) as dinheiro,
							sum(outrosreceb) as outrosreceb,
							sum(postotalamount) as postotalamount,
							sum(totalamount) as totalamount
						from
							(
							select 
								pay.billingaccountid as billingaccountidpay,
								case 
									when payit.paymenttypeid = 2 -- and pay.integrationcode is null 
									then pay.amount 
									else 0 
								end as deposito,
								case 
									when payit.paymenttypeid = 5 --and pay.integrationcode is null 
									then pay.amount 
									else 0 
								end as cartao,
								case 
									when payit.paymenttypeid = 6 --and pay.integrationcode is null 
									then pay.amount 
									else 0 
									end
                                         as faturar,
								case 
									when payit.paymenttypeid = 7 --and pay.integrationcode is null 
									then pay.amount 
									else 0 end
                                         as cheque,
								case 
									when payit.paymenttypeid = 8 -- and pay.integrationcode is null 
									then pay.amount 
									else 0 
									end
                                         as dinheiro,
								case 
									when 
									(
                                    payit.billingitemtypeid = 3 and payit.paymenttypeid not in 
										(2,5,6,7,8)
                                    ) 
									then pay.amount 
									else 0 
								end as outrosreceb,
								case 
									when payit.billingitemtypeid = 4
									then pay.amount
									else 0
								end as postotalamount,
								case 
									when payit.billingitemtypeid = 3
                                    then pay.amount 
									else 0 
								end as totalamount
                            from billingaccountitem as pay
                            join billingitem as payit 
								on pay.billingitemid = payit.billingitemid
                                and pay.isdeleted = false
                            where pay.tenantid::uuid ='2cecdbc0-7de2-45a9-9a19-edcaec7268c3'::uuid
                            AND pay.billingaccountid IN ( SELECT billingaccountid 
                                     					  FROM billinginvoice bidisc
							                              WHERE bidisc.tenantid::uuid ='2cecdbc0-7de2-45a9-9a19-edcaec7268c3'::uuid and coalesce(bidisc.externalemissiondate::date,bidisc.emissiondate::date)='2023-10-04'
							                            )
                            ) pay 
                            group by billingaccountidpay
                        )
						, discount as
						(
                        select
							sum(
							case 
								when discount.billingaccountitemtypeid = 5 and cast(discount.wasreversed as int) = 0 
								then discount.amount 
								else 0 
								end) as discamount,
							discount.billingaccountid as billingaccountiddisc
                        from billingaccountitem as discount
                        inner join billinginvoice bidisc 
							on discount.billinginvoiceid = bidisc.billinginvoiceid
                        where discount.tenantid ='2cecdbc0-7de2-45a9-9a19-edcaec7268c3'::uuid and coalesce(bidisc.externalemissiondate::date,bidisc.emissiondate::date)='2023-10-04'
						group by
							discount.billingaccountid
						)
                        select
							NT.*,
							PY.billingaccountidpay,
							case when NT.statusid = 14 then 0 else PY.postotalamount end as postotalamount,
							case when NT.statusid = 14 then 0 else PY.deposito end as deposito,
							case when NT.statusid = 14 then 0 else PY.cartao end as cartao,
							case when NT.statusid = 14 then 0 else PY.faturar end as faturar,
							case when NT.statusid = 14 then 0 else PY.cheque end as cheque,
							case when NT.statusid = 14 then 0 else PY.dinheiro end as dinheiro,
							case when NT.statusid = 14 then 0 else PY.outrosreceb end as outrosreceb,
							case when NT.statusid = 14 then 0 else PY.totalamount end as totalamount, 
							DS.discamount,
                            DS.billingaccountiddisc
                        from nota NT
                        left join pay PY on NT.billingaccountid = PY.billingaccountidpay
                        left join discount DS on PY.billingaccountidpay = DS.billingaccountiddisc
                        order by
                          char_length(NT.number),
                          NT.number,
                          char_length(NT.rps),
                          NT.rps
					) a

                --var queryNFe = $@"
                    select
					   	billingaccountid,
						recipientsname,
						roomnumber,
						numreserva,
						nomeconta,
						type,
						number,
						serie,
						rps,
						emissiondate,
						canceldate,
						status,
						deposito,
						cartao,
						faturar,
						cheque,
						dinheiro,
						outrosreceb,
						discamount as desconto,
						restaurante,
						outros,
						bares,
						diaria,
						eventos,
						banquetes,
						lavandeira,
						telecomunicacoes,
						iss,
						taxadeservico,
						COALESCE(total,0) + COALESCE(discamount,0) + COALESCE (postotalamount*-1,0) as total,
						servico,
						taxa,
						COALESCE(totalamount,0) + COALESCE(discamount,0) + COALESCE (postotalamount*-1,0) as tipopagamento,                             
						pontodevenda,
						statusid,
						billinginvoicetypeid,
						symbol,
						aditionaldetails,
						integratorlink,
						integratorxml,
						errordate,
						billinginvoiceid,
						internalcomments,
						externalcomments,
						partnercomments,
                        totalamount,
                        postotalamount
					from
					(
						with nota as 
						(
						select
                            ba.billingaccountid,
							case ba.billingaccounttypeid 
                            	when {(int)BillingAccountTypeEnum.Sparse } 
                            	then COALESCE(header.fullname, cia.tradename) 
                            	when {(int)BillingAccountTypeEnum.Guest } 
                            	then COALESCE(header.fullname, gri.guestname) 
                            	when {(int)BillingAccountTypeEnum.Company } 
                            	then COALESCE(header.fullname, cia.tradename) 
                            	when {(int)BillingAccountTypeEnum.GroupAccount } 
                            	then COALESCE(header.fullname,cia.tradename,gri.guestname) 
                            end as recipientsname,
                            uh.roomnumber,
                            COALESCE(rf.reservationitemcode, '') as numreserva,
                            COALESCE(ba.billingaccountname, 'GERAL') as nomeconta,
							case when bi.externalnumber is not null then bm.description else 'RPS' end as type,
                            COALESCE (bi.externalnumber,bi.billinginvoicenumber) as number,
                            COALESCE (bi.externalseries,bi.billinginvoiceseries) as serie,
                            COALESCE (bi.externalrps,bi.billinginvoicenumber) as rps,
                            COALESCE (bi.externalemissiondate,bi.emissiondate) as emissiondate,
                            cast(bi.canceldate as date),
							case bi.billinginvoicestatusid 
                            	when {(int)BillingInvoiceStatusEnum.NotSent } 
                            	then 'Nao Enviada' 
                            	when {(int)BillingInvoiceStatusEnum.Issued } 
                            	then 'Emitida' 
                            	when {(int)BillingInvoiceStatusEnum.Pending } 
                            	then 'Pendente' 
                            	when {(int)BillingInvoiceStatusEnum.Error } 
                            	then 'Erro' 
                            	when {(int)BillingInvoiceStatusEnum.Canceling } 
                            	then 'Cancelando' 
                           		when 14 
                           		then 'Cancelada' 
                            end as status,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Restaurant } and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Restaurant } 
								then lf.amount 
								else 0 
							end) as restaurante,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Others } and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Others } 
								then lf.amount 
								else 0 
							end) as outros,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Pubs } and st.statusid = 14 
								then 0
                                when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Pubs } 
								then lf.amount 
                                else 0 
							end) as bares,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Daily } and st.statusid = 14 
								then 0
                                when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Daily } 
								then lf.amount 
                                else 0
							end) as diaria,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Events } and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Events } 
								then lf.amount 
								else 0 
							end) as eventos,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Banquets } and st.statusid = 14 
								then 0
                                when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Banquets } 
								then lf.amount
								else 0 
							end) as banquetes,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Laundry } and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Laundry } 
								then lf.amount 
								else 0 
							end) as lavandeira,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Telecommunications } and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.Telecommunications } 
								then lf.amount 
								else 0 
								end) as telecomunicacoes,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.ISS } and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.ISS } 
								then lf.amount 
								else 0 end
                                        ) as iss,
							sum(
							case 
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.ServiceFee } and st.statusid = 14 
								then 0
								when gf.billingitemcategoryid = {(int)BillingItemCategoryEnum.ServiceFee } 
								then lf.amount 
								else 0 
								end) as taxadeservico,
							sum(
							case 
								when tl.billingitemtypeid = {(int)BillingItemTypeEnum.Service } and st.statusid = 14 
								then 0
								when tl.billingitemtypeid = {(int)BillingItemTypeEnum.Service } 
								then lf.amount 
								else 0 
								end) as servico,
							sum(
							case 
								when gf.billingitemcategoryid in ({(int)BillingItemCategoryEnum.ISS },{(int)BillingItemCategoryEnum.ServiceFee }) and st.statusid = 14 then 0
								when gf.billingitemcategoryid in ({(int)BillingItemCategoryEnum.ISS },{(int)BillingItemCategoryEnum.ServiceFee }) 
								then lf.amount 
								else 0 
							end) as taxa,
							sum(
							case 
								when tl.billingitemtypeid = {(int)BillingItemTypeEnum.Service } and st.statusid = 14 
								then 0
								when tl.billingitemtypeid = {(int)BillingItemTypeEnum.Service } 
								then lf.amount 
								else 0 
							end) as pontodevenda,
							sum(
							case 
								when tl.billingitemtypeid in ({(int)BillingItemTypeEnum.Service },{(int)BillingItemTypeEnum.Tax }) and st.statusid = 14 
								then 0 
								when tl.billingitemtypeid in ({(int)BillingItemTypeEnum.Service },{(int)BillingItemTypeEnum.Tax }) 
								then lf.amount*-1 
								else 0 
							end) as total,
							st.statusid,
							bi.billinginvoicetypeid,
							max(symbol) as symbol,
							bi.aditionaldetails,
							bi.integratorlink,
							bi.integratorxml,
							bi.errordate,
							bi.billinginvoiceid,
							rr.internalcomments,
							rr.externalcomments,
							rr.partnercomments
						FROM property as pr
                        join billingaccount as ba
                        	on pr.tenantid::uuid = ba.tenantid::uuid
                        join billinginvoice as bi 
                        	on pr.tenantid::uuid = bi.tenantid::uuid
                            and bi.billingaccountid = ba.billingaccountid
                        join billinginvoiceproperty as bp 
                        	on bi.tenantid::uuid = bp.tenantid::uuid
                        	and bi.billinginvoicepropertyid = bp.billinginvoicepropertyid
                        	AND bp.isintegrated = TRUE
                        	AND bp.isactive = TRUE
                        	AND bp.isdeleted =FALSE
                        join billinginvoicepropertysupportedtype bs
                        	on bp.tenantid::uuid= bs.tenantid::uuid
							and bp.billinginvoicepropertyid = bs.billinginvoicepropertyid
							and bs.isdeleted = FALSE
                        join billinginvoicemodel as bm 
                        	on bp.billinginvoicemodelid = bm.billinginvoicemodelid 
                        left join billingaccountitem as lf 
                            on bi.billingaccountid = lf.billingaccountid 
                            and bi.billinginvoiceid = lf.billinginvoiceid
                            and bs.billingitemid = lf.billingitemid
                            and lf.isdeleted = false
                        left join billingitem as td 
                            on lf.tenantid::uuid=td.tenantid::uuid
                            and lf.billingitemid=td.billingitemid 
                        join status as st 
                        	on st.statusid = bi.billinginvoicestatusid
                        left join billingitemcategory as gr 
                        	on td.billingitemcategoryid = gr.billingitemcategoryid
                        left join billingitemcategory as gf 
                        	on gr.standardcategoryid = gf.billingitemcategoryid
                        left join billingitemtype as tl 
                        	on td.billingitemtypeid = tl.billingitemtypeid
                        left join reservationitem as rf 
                        	on ba.reservationitemid = rf.reservationitemid
                        left join person as header 
                        	on header.personid = bi.personheaderid
                        left join guestreservationitem as gri 
                        	on ba.guestreservationitemid = gri.guestreservationitemid
                        left join companyclient as cia 
                        	on cia.companyclientid = ba.companyclientid
                        left join reservation as rr 
                        	on rf.reservationid = rr.reservationid
                        left join companyclient as cc 
                        	on rr.companyclientid = cc.companyclientid
                        left join room as uh 
							on rf.roomid = uh.roomid
						left join currency as c 
							on lf.currencyid = c.currencyid
						where
						pr.tenantid::uuid = '{tenantid}' { filters }
						group by
							ba.billingaccountid,
							bi.externalrps,
							pr.propertyid,
							uh.roomnumber,
							COALESCE(rf.reservationitemcode, ''),
							COALESCE(ba.billingaccountname, 'GERAL'),
							ba.billingaccounttypeid,
							bi.billinginvoicenumber,
							COALESCE(bi.externalemissiondate,bi.emissiondate),
							bi.canceldate,
							bi.billinginvoicestatusid,
							bm.description,
							bi.externalnumber,
							bi.externalseries,
							st.statusid,
							bi.billinginvoicetypeid,
							bi.externalemissiondate,
							bi.aditionaldetails,
							bi.integratorlink,
							bi.integratorxml,
							bi.errordate,
							bi.billinginvoiceid,
							rr.internalcomments,
							rr.externalcomments,
							rr.partnercomments,
							case ba.billingaccounttypeid when {(int)BillingAccountTypeEnum.Sparse } then COALESCE(header.fullname, cia.tradename) when {(int)BillingAccountTypeEnum.Guest } then COALESCE(header.fullname, gri.guestname) when {(int)BillingAccountTypeEnum.Company } then COALESCE(header.fullname, cia.tradename) when {(int)BillingAccountTypeEnum.GroupAccount } then COALESCE(header.fullname, cia.tradename, gri.guestname) end
						)
						, pay as 
                        (
						select 
							billingaccountidpay,
							sum(deposito) as deposito,
							sum(cartao) as cartao,
							sum(faturar) as faturar,
							sum(cheque) as cheque,
							sum(dinheiro) as dinheiro,
							sum(outrosreceb) as outrosreceb,
							sum(postotalamount) as postotalamount,
							sum(totalamount) as totalamount
						from
							(
							select 
								pay.billingaccountid as billingaccountidpay,
								case 
									when payit.paymenttypeid = {(int)PaymentTypeEnum.Deposit } and pay.integrationcode is null 
									then pay.amount 
									else 0 
								end as deposito,
								case 
									when payit.paymenttypeid = {(int)PaymentTypeEnum.CreditCard } and pay.integrationcode is null 
									then pay.amount 
									else 0 
								end as cartao,
								case 
									when payit.paymenttypeid = {(int)PaymentTypeEnum.TobeBilled } and pay.integrationcode is null 
									then pay.amount 
									else 0 
									end
                                         as faturar,
								case 
									when payit.paymenttypeid = {(int)PaymentTypeEnum.Check } and pay.integrationcode is null 
									then pay.amount 
									else 0 end
                                         as cheque,
								case 
									when payit.paymenttypeid = {(int)PaymentTypeEnum.Money } and pay.integrationcode is null 
									then pay.amount 
									else 0 
									end
                                         as dinheiro,
								case 
									when 
									(
                                    payit.billingitemtypeid = {(int)BillingItemTypeEnum.PaymentType} and payit.paymenttypeid not in 
										(
                                        {(int)PaymentTypeEnum.Deposit },
                                        {(int)PaymentTypeEnum.CreditCard },
                                        {(int)PaymentTypeEnum.TobeBilled },
                                        {(int)PaymentTypeEnum.Check },
                                        {(int)PaymentTypeEnum.Money }  )
                                    ) 
									then pay.amount 
									else 0 
								end as outrosreceb,
								case 
									when payit.billingitemtypeid = {(int)BillingItemTypeEnum.PointOfSale} 
									then pay.amount
									else 0
								end as postotalamount,
								case 
									when payit.billingitemtypeid = {(int)BillingItemTypeEnum.PaymentType}
                                    then pay.amount 
									else 0 
								end as totalamount
                            from billingaccountitem as pay
                            join billingitem as payit 
								on pay.billingitemid = payit.billingitemid
                                and pay.isdeleted = false
                            where pay.tenantid::uuid = '{tenantid}' 
                            AND pay.billingaccountid IN ( SELECT billingaccountid 
                                     					  FROM billinginvoice bidisc
							                              WHERE bidisc.tenantid::uuid = '{tenantid}' { filtersDate }
							                            )
                            ) pay 
                            group by billingaccountidpay
                        )
						, discount as
						(
                        select
							sum(
							case 
								when discount.billingaccountitemtypeid = {(int)BillingAccountItemTypeEnum.BillingAccountItemTypeDiscount } and cast(discount.wasreversed as int) = 0 
								then discount.amount 
								else 0 
								end) as discamount,
							discount.billingaccountid as billingaccountiddisc
                        from billingaccountitem as discount
                        inner join billinginvoice bidisc 
							on discount.billinginvoiceid = bidisc.billinginvoiceid
                        where discount.tenantid::uuid = '{tenantid}' { filtersDate }
						group by
							discount.billingaccountid
						)
                        select
							NT.*,
							PY.billingaccountidpay,
							case when NT.statusid = 14 then 0 else PY.postotalamount end as postotalamount,
							case when NT.statusid = 14 then 0 else PY.deposito end as deposito,
							case when NT.statusid = 14 then 0 else PY.cartao end as cartao,
							case when NT.statusid = 14 then 0 else PY.faturar end as faturar,
							case when NT.statusid = 14 then 0 else PY.cheque end as cheque,
							case when NT.statusid = 14 then 0 else PY.dinheiro end as dinheiro,
							case when NT.statusid = 14 then 0 else PY.outrosreceb end as outrosreceb,
							case when NT.statusid = 14 then 0 else PY.totalamount end as totalamount,
                            DS.discamount,
                            DS.billingaccountiddisc
                        from nota NT
                        left join pay PY on NT.billingaccountid = PY.billingaccountidpay
                        left join discount DS on PY.billingaccountidpay = DS.billingaccountiddisc
                        order by
                          char_length(NT.number),
                          NT.number,
                          char_length(NT.rps),
                          NT.rps
					) a