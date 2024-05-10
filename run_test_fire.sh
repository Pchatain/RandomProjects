datasets=()
datasets+=("epic_ello_valid")
datasets+=("audiocapture_230315_beta_val_localfsx")
datasets+=("ello_launch_books")
datasets+=("audiocapture_230315_beta_test")
datasets+=("epic_ello_test")
datasets+=("cmu_kids_all")

models=()
models+=("w2v_slim_finetune_ack1_causal_mask-2024-03-19-13-37")
models+=("w2v_slim_finetune_ack1_causal_mask_lookahead1-2024-03-22-20-19")
models+=("w2v_slim_finetune_ack1_causal_mask_lookahead5-2024-03-22-20-17")
models+=("w2v_slim_finetune_ack1_causal_mask_pos_conv1-2024-03-27-01-45")
models+=("w2v_slim_finetune_ack1_causal_mask_pos_conv2-2024-03-27-02-01")
models+=("base_pretrain_ls_finetune_ac1k")
models+=("w2v_base_finetune_ack1_causal_mask-2024-03-08-20-03")
datasets_str="["
for dataset in "${datasets[@]}"
do
    datasets_str+="'$dataset',"
done
datasets_str+="]"
echo $datasets_str

models_str="["
for model in "${models[@]}"
do
    models_str+="'$model',"
done
models_str+="]"
echo $models_str
# python -m test_fire --arg1 "$models_str"


python -m test_fire --arg1 '{"causal_mask": False}'