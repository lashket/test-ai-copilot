import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task_oncom/generated/l10n.dart';

class BaseInput extends StatelessWidget {
  const BaseInput({
    required this.onSubmit,
    super.key,
    this.validator,
    this.busy = false,
  });

  final String? Function(String?)? validator;
  final void Function(String text) onSubmit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InputCubit(validator: validator),
      child: _InputField(onSubmit: onSubmit, busy: busy),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.onSubmit, required this.busy});

  final void Function(String text) onSubmit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InputCubit>();
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<InputCubit, InputState>(
            builder: (context, state) {
              return TextField(
                controller: cubit.ctrl,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: S.of(context).typeYourMessage,
                  errorText: state.error,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: cubit.onChanged,
                onSubmitted: (_) => _submit(context),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: busy ? null : () => _submit(context),
          icon: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final cubit = context.read<InputCubit>();
    if (!cubit.validate()) return;
    final text = cubit.ctrl.text.trim();
    if (text.isEmpty || busy) return;
    onSubmit(text);
    cubit.clear();
  }
}

class InputCubit extends Cubit<InputState> {
  InputCubit({this.validator}) : super(const InputState());
  final String? Function(String?)? validator;
  final TextEditingController ctrl = TextEditingController();

  void onChanged(String _) {
    if (state.error != null) validate();
  }

  bool validate() {
    final err = validator?.call(ctrl.text);
    if (err != state.error) emit(state.copyWith(error: err));
    return err == null;
  }

  void clear() {
    ctrl.clear();
    emit(const InputState());
  }

  @override
  Future<void> close() {
    ctrl.dispose();
    return super.close();
  }
}

class InputState extends Equatable {
  const InputState({this.error});
  final String? error;

  InputState copyWith({String? error}) => InputState(error: error);

  @override
  List<Object?> get props => [error];
}
