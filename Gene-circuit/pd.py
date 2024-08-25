def evaluate_conditions(conditions: list[str], environment_variables: dict):
    global gal4_vp16, luciferase, ins, gal4, vp16, vp16_gi, vp16_lov, gal4_gi, gal4_lov,circrna, miRNA, gi_lov, blood_sugar, blueray
    # 初始化变量状态
    gal4_vp16 = False
    luciferase = False
    ins = False
    gal4 = False
    vp16 = False
    vp16_gi = False
    vp16_lov = False
    gal4_gi = False
    gal4_lov = False
    circrna = False
    miRNA = False
    gi_lov = False
    blood_sugar=environment_variables["blood_sugar"]
    blueray=environment_variables["blueray"]
    conditions_to_skip = set()  # Used to store conditions that need to be skipped


    print("condition:")
    print(conditions)
    #The first loop: handles the promoter
    for condition in conditions:
        parts = condition.split('-')
        if parts[0] in ['CMV', 'U6_P', 'P_GIP'] and 'miRNA_BS' not in condition:
            process_parts(parts)
        else:
            conditions_to_skip.add(condition)

    #Second loop: process 9XUAS
    for condition in conditions:
        if condition in conditions_to_skip:
            parts = condition.split('-')
            if '9XUAS' in parts:
                process_parts_after_9XUAS(parts)

    # Third cycle: Processing miRNA-BS
    for condition in conditions:
        parts = condition.split('-')
        if 'miRNA_BS' in parts:
            handle_miRNA_BS(parts)

    return determine_result()

def process_parts(parts):
    global gal4_vp16, luciferase, ins, gal4, vp16, vp16_gi, vp16_lov, gal4_gi, gal4_lov,miRNA,circrna
    if parts[0] in'P_GIP'and blood_sugar<50:
        return
    if 'GAL4' in parts and 'VP16' in parts:
        gal4_vp16 = True
    elif 'VP16' in parts and 'GI' in parts:
        vp16_gi = True 
    elif  'VP16' in parts and 'LOV' in parts:
        vp16_lov = True 
    elif 'GAL4' in parts and 'GI' in parts:
        gal4_gi = True  
    elif  'GAL4' in parts and 'LOV' in parts:
        gal4_lov = True
    if gal4_gi == True and vp16_lov == True:
        gal4_vp16 = True
    elif vp16_gi == True and gal4_lov == True:
        gal4_vp16 = True
    if 'Luciferase' in parts:
        luciferase = True
    if 'INS' in parts:
        ins = True
    if 'miRNA' in parts:
        miRNA = True
    if 'circRNA' in parts:
        circrna = True
    if miRNA == True and circrna == True:
        miRNA=False

def process_parts_after_9XUAS(parts):
    index = parts.index('9XUAS')
    if 'miRNA_BS' not in parts and gal4_vp16==True:
        process_parts(parts[index+1:])
    else:
        print("UAS判断特殊情况")

def handle_miRNA_BS(parts):
    global circrna, miRNA
    index = parts.index('miRNA_BS')
    if miRNA == False and '9XUAS' in parts:
        process_parts_after_9XUAS(parts[:index])
    elif miRNA ==False and '9XUAS' not in parts:
        process_parts(parts[:index])

def determine_result():
    if luciferase and ins:
        return '绿光+血糖'
    elif luciferase:
        return '绿光'
    elif ins:
        return '血糖'
    else:
        return '无结果'
    
# # conditions = [
#     'INS-miRNA_BS',
#     'P_GIP-VP16-GI',
#     'U6_P-miRNA',
#     'P_GIP-circRNA',
#     'CMV-GAL4-LOV'
# ]
# result = evaluate_conditions(conditions, {"blood_sugar": 50, "blueray": True})
# print(result)
